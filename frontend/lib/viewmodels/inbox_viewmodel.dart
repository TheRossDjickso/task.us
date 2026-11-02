import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'project_viewmodel.dart';

class InboxState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  // Tracks individual accept/decline loading by notification id.
  final Map<String, bool> actionLoadingState;

  const InboxState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.actionLoadingState = const {},
  });

  InboxState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    Map<String, bool>? actionLoadingState,
  }) {
    return InboxState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      actionLoadingState: actionLoadingState ?? this.actionLoadingState,
    );
  }
}

class InboxViewModel extends StateNotifier<InboxState> {
  final NotificationService _notificationService;
  final Ref _ref;

  InboxViewModel(this._notificationService, this._ref)
      : super(const InboxState()) {
    loadLocalNotifications().then((_) => loadNotifications());
  }

  /// Loads cached notifications from SharedPreferences.
  Future<void> loadLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cached_notifications');
      if (jsonStr != null) {
        final List<dynamic> decoded = json.decode(jsonStr);
        final list = decoded
            .map((item) => NotificationModel.fromJson(item))
            .toList();
        state = state.copyWith(notifications: list);
      }
    } catch (e) {
      developer.log('Error loading local notifications: $e');
    }
  }

  /// Caches the current notifications list into SharedPreferences.
  Future<void> saveNotificationsLocally(List<NotificationModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(list.map((n) => n.toJson()).toList());
      await prefs.setString('cached_notifications', jsonStr);
    } catch (e) {
      developer.log('Error caching notifications locally: $e');
    }
  }

  /// Loads all notifications from the backend API.
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _notificationService.getNotifications();
      state = state.copyWith(isLoading: false, notifications: list);
      await saveNotificationsLocally(list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String id) async {
    try {
      final updatedList = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedList);
      await saveNotificationsLocally(updatedList);

      await _notificationService.markAsRead(id);
      loadNotifications();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      final updatedList = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      state = state.copyWith(notifications: updatedList);
      await saveNotificationsLocally(updatedList);

      await _notificationService.markAllAsRead();
      loadNotifications();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Accepts a project invitation, reloads notifications and projects.
  Future<void> acceptInvitation(NotificationModel notification) async {
    final projectId = notification.payload['projectId']?.toString();
    if (projectId == null) {
      return;
    }

    _setActionLoading(notification.id, true);

    try {
      await _notificationService.acceptInvitation(projectId);
      await _notificationService.markAsRead(notification.id);
      await _ref.read(projectViewModelProvider.notifier).loadProjects();
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      _setActionLoading(notification.id, false);
    }
  }

  /// Declines a project invitation, marks it as read, and reloads.
  Future<void> declineInvitation(NotificationModel notification) async {
    final projectId = notification.payload['projectId']?.toString();
    if (projectId == null) {
      return;
    }

    _setActionLoading(notification.id, true);

    try {
      await _notificationService.declineInvitation(projectId);
      await _notificationService.markAsRead(notification.id);
      await loadNotifications();
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      _setActionLoading(notification.id, false);
    }
  }

  void _setActionLoading(String notificationId, bool isLoading) {
    final updatedMap = Map<String, bool>.from(state.actionLoadingState);
    if (isLoading) {
      updatedMap[notificationId] = true;
    } else {
      updatedMap.remove(notificationId);
    }
    state = state.copyWith(actionLoadingState: updatedMap);
  }
}

// Global service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// StateNotifierProvider for Inbox Screen
final inboxViewModelProvider =
    StateNotifierProvider<InboxViewModel, InboxState>(
  (ref) {
    final service = ref.watch(notificationServiceProvider);
    return InboxViewModel(service, ref);
  },
);

/// Derived provider that reactively computes the count
/// of unread project invitations for the badge display.
final unreadInviteCountProvider = Provider<int>((ref) {
  final state = ref.watch(inboxViewModelProvider);
  return state.notifications
      .where(
        (n) => n.type == 'project:invite' && !n.isRead,
      )
      .length;
});

/// Derived provider that reactively computes the count
/// of all unread notifications for the badge display.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(inboxViewModelProvider);
  return state.notifications.where((n) => !n.isRead).length;
});
