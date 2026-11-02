import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';
import '../services/secure_storage_service.dart';
import 'inbox_viewmodel.dart';

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthViewModel(this._authService, this._ref)
      : super(const AsyncValue.data(null)) {
    _checkSavedLogin();
  }

  /// Reloads inbox notifications when a foreground FCM message arrives.
  /// This is the callback wired into PushNotificationService.initialize
  /// so that the nav bar badge updates in real time.
  void _onForegroundMessage(RemoteMessage _) {
    _ref.read(inboxViewModelProvider.notifier).loadNotifications();
  }

  Future<void> _checkSavedLogin() async {
    final token = await SecureStorageService().getAuthToken();
    if (token != null) {
      try {
        state = const AsyncValue.loading();
        final user = await _authService.getMe();
        state = AsyncValue.data(user);
        // Initialize push notifications after verifying saved login
        PushNotificationService().initialize(
          ref: _ref,
          onForegroundMessage: _onForegroundMessage,
        );
      } catch (e) {
        await SecureStorageService().deleteAuthToken();
        state = const AsyncValue.data(null);
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final result = await _authService.login(email, password);
      final user = result['user'] as User;
      final token = result['token'] as String;

      await SecureStorageService().saveAuthToken(token);

      state = AsyncValue.data(user);
      // Initialize push notifications after login
      PushNotificationService().initialize(
        ref: _ref,
        onForegroundMessage: _onForegroundMessage,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      state = const AsyncValue.loading();
      final result = await _authService.register(
        fullName,
        email,
        password,
      );
      final user = result['user'] as User;
      final token = result['token'] as String;

      await SecureStorageService().saveAuthToken(token);

      state = AsyncValue.data(user);
      // Initialize push notifications after register
      PushNotificationService().initialize(
        ref: _ref,
        onForegroundMessage: _onForegroundMessage,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    // Unregister token first while we still have credentials
    await PushNotificationService().cleanUp();
    await SecureStorageService().deleteAuthToken();
    state = const AsyncValue.data(null);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthViewModel(service, ref);
});

