import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notification_model.dart';
import '../../viewmodels/inbox_viewmodel.dart';

/// Premium Inbox Screen showing real-time invitations and notifications.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(inboxViewModelProvider);
    final notifier = ref.read(inboxViewModelProvider.notifier);

    // Watch for errors and display elegant snackbars if present.
    ref.listen<InboxState>(inboxViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8.0),
                Expanded(child: Text(next.error!)),
              ],
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      }
    });

    // Filter to active pending project invitations.
    final pendingInvites = state.notifications
        .where((n) => n.type == 'project:invite' && !n.isRead)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inbox',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3035),
                    ),
                  ),
                  if (pendingInvites.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87941).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '${pendingInvites.length} en attente',
                        style: TextStyle(
                          color: const Color(0xFFF87941),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFF87941),
                  onRefresh: () => notifier.loadNotifications(),
                  child: state.isLoading && pendingInvites.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF87941),
                          ),
                        )
                      : pendingInvites.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: pendingInvites.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16.0),
                              itemBuilder: (context, index) {
                                final item = pendingInvites[index];
                                return _buildInviteItem(
                                  context: context,
                                  notification: item,
                                  isActionLoading: state.actionLoadingState[item.id] ?? false,
                                  onAccept: () => notifier.acceptInvitation(item),
                                  onDecline: () => notifier.declineInvitation(item),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 20,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87941).withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mail_outline_rounded,
                      size: 64.0,
                      color: Color(0xFFF87941),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Boîte de réception vide',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F3035),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Vous n\'avez reçu aucune invitation à collaborer sur des projets pour le moment.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8F9095),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteItem({
    required BuildContext context,
    required NotificationModel notification,
    required bool isActionLoading,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    final theme = Theme.of(context);
    final payload = notification.payload;
    final projectName = payload['projectName'] ?? payload['projectName'] ?? 'Projet Collaboratif';
    final senderName = payload['senderName'] ?? 'Un utilisateur';
    final role = payload['role'] ?? 'member';

    String roleLabel = 'Membre';
    Color roleColor = const Color(0xFFF87941);
    if (role == 'admin') {
      roleLabel = 'Administrateur';
      roleColor = const Color(0xFFE53935);
    } else if (role == 'viewer') {
      roleLabel = 'Observateur';
      roleColor = const Color(0xFF4CAF50);
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE6E4E6),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x052F3035),
            blurRadius: 10.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF87941).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFFF87941),
                    size: 20.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F3035),
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: [
                        Text(
                          'Vous invite à rejoindre en tant que : ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8F9095),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF87941).withOpacity(0.04),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFF87941).withOpacity(0.1),
                width: 1.0,
              ),
            ),
            child: Text(
              projectName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2F3035),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          if (isActionLoading)
            const Center(
              child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Color(0xFFF87941),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE6E4E6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: onDecline,
                    child: const Text(
                      'Refuser',
                      style: TextStyle(
                        color: Color(0xFF2F3035),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF87941),
                      foregroundColor: const Color(0xFFFDFCFC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: onAccept,
                    child: const Text(
                      'Accepter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
