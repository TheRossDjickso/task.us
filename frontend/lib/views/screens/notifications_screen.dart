import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notification_model.dart';
import '../../services/notification_navigation_helper.dart';
import '../../viewmodels/inbox_viewmodel.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} j';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _getTitle(NotificationModel notification) {
    switch (notification.type) {
      case 'project:invite':
        return 'Invitation à un projet';
      case 'project:added':
        return 'Ajout à un projet';
      case 'task:assigned':
        return 'Nouvelle tâche assignée';
      case 'comment:added':
        return 'Nouveau commentaire';
      case 'comment:mention':
        return 'Mention dans un commentaire';
      case 'task:updated':
        return 'Tâche mise à jour';
      default:
        return 'Nouvelle notification';
    }
  }

  String _getBody(NotificationModel notification) {
    final payload = notification.payload;
    final projectName = payload['projectName']?.toString() ??
        payload['projectTitle']?.toString() ??
        'un projet';
    final senderName = payload['senderName']?.toString() ??
        payload['authorName']?.toString() ??
        'Un utilisateur';
    final taskTitle = payload['taskTitle']?.toString() ??
        payload['title']?.toString() ??
        'une tâche';

    switch (notification.type) {
      case 'project:invite':
        return '$senderName vous a invité à rejoindre le projet '
            '"$projectName".';
      case 'project:added':
        return 'Vous avez été ajouté au projet "$projectName".';
      case 'task:assigned':
        return 'Vous avez été assigné à la tâche "$taskTitle".';
      case 'comment:added':
        return '$senderName a commenté la tâche "$taskTitle".';
      case 'comment:mention':
        return '$senderName vous a mentionné sur la tâche "$taskTitle".';
      case 'task:updated':
        return 'La tâche "$taskTitle" a été mise à jour.';
      default:
        return 'Vous avez reçu une notification.';
    }
  }

  IconData _getIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'project:invite':
      case 'project:added':
        return Icons.group_add_rounded;
      case 'task:assigned':
        return Icons.assignment_ind_rounded;
      case 'comment:added':
      case 'comment:mention':
        return Icons.comment_rounded;
      case 'task:updated':
        return Icons.edit_note_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxViewModelProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    // Sort: newest first
    final list = state.notifications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2F3035)),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF2F3035),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(inboxViewModelProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'Tout lire',
                style: TextStyle(
                  color: Color(0xFFF87941),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF87941),
        backgroundColor: const Color(0xFFFDFCFC),
        onRefresh: () =>
            ref.read(inboxViewModelProvider.notifier).loadNotifications(),
        child: state.isLoading && list.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF87941)),
              )
            : list.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE6E4E6),
                    ),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _buildNotificationItem(context, ref, item);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Color(0xFFB1B1B1),
              ),
              SizedBox(height: 16.0),
              Text(
                'Aucune notification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F3035),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Vous êtes à jour !',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB1B1B1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationModel item,
  ) {
    return InkWell(
      onTap: () {
        NotificationNavigationHelper.handleNotificationTap(
          type: item.type,
          payload: item.payload,
          ref: ref,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.transparent
              : const Color(0xFFF87941).withValues(alpha: 0.04),
          border: item.isRead
              ? null
              : const Border(
                  left: BorderSide(
                    color: Color(0xFFF87941),
                    width: 4.0,
                  ),
                ),
        ),
        padding: EdgeInsets.only(
          left: item.isRead ? 16.0 : 12.0,
          right: 16.0,
          top: 16.0,
          bottom: 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon badge
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF87941),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(item),
                color: const Color(0xFFFDFCFC),
                size: 20,
              ),
            ),
            const SizedBox(width: 12.0),
            // Title & body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTitle(item),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: const Color(0xFF2F3035),
                        ),
                      ),
                      Text(
                        _formatDate(item.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB1B1B1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    _getBody(item),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: item.isRead
                          ? const Color(0xFF57423A)
                          : const Color(0xFF2F3035),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 8.0),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF87941),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
