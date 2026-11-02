import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/manage_members_viewmodel.dart';
import '../widgets/invite_member_modal.dart';

class ManageMembersScreen extends ConsumerWidget {
  final String projectId;

  const ManageMembersScreen({
    super.key,
    required this.projectId,
  });

  /// Returns a French display label for a backend role.
  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Propriétaire';
      case 'admin':
        return 'Administrateur';
      case 'member':
        return 'Membre';
      case 'viewer':
        return 'Observateur';
      default:
        return role;
    }
  }

  /// Returns a color for each role badge.
  Color _roleBadgeColor(String role) {
    switch (role) {
      case 'owner':
        return const Color(0xFFF87941); // Precious Persimmon
      case 'admin':
        return const Color(0xFF6366F1); // Indigo
      case 'member':
        return const Color(0xFF22C55E); // Green
      case 'viewer':
        return const Color(0xFFB1B1B1); // Palladium
      default:
        return const Color(0xFFB1B1B1);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(manageMembersViewModelProvider(projectId));
    final viewModel =
        ref.read(manageMembersViewModelProvider(projectId).notifier);

    final filteredMembers = viewModel.filteredMembers;

    final activeMembers = filteredMembers.where((m) => !m.isPending).toList();
    final pendingMembers = filteredMembers.where((m) => m.isPending).toList();

    // The owner is always first, then other active members.
    final ownerMembers =
        activeMembers.where((m) => m.role == 'owner').toList();
    final otherActiveMembers =
        activeMembers.where((m) => m.role != 'owner').toList();
    final sortedActiveMembers = [...ownerMembers, ...otherActiveMembers];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          'Gestion des membres',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            )
          : state.error != null && state.members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => viewModel.loadMembers(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => viewModel.loadMembers(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary line
                        Text(
                          '${state.members.length} membre${state.members.length > 1 ? 's' : ''} dans ce projet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Search bar + role filter
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: viewModel.setSearchQuery,
                                decoration: InputDecoration(
                                  hintText: 'Rechercher un membre...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                        color:
                                            theme.colorScheme.outlineVariant),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: state.roleFilter,
                                  icon: const Icon(Icons.filter_list),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      viewModel.setRoleFilter(newValue);
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'all', child: Text('Tous')),
                                    DropdownMenuItem(
                                        value: 'owner',
                                        child: Text('Propriétaire')),
                                    DropdownMenuItem(
                                        value: 'admin',
                                        child: Text('Admin')),
                                    DropdownMenuItem(
                                        value: 'member',
                                        child: Text('Membre')),
                                    DropdownMenuItem(
                                        value: 'viewer',
                                        child: Text('Observateur')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Active members section
                        if (sortedActiveMembers.isNotEmpty) ...[
                          Text(
                            'Membres actifs (${sortedActiveMembers.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ...sortedActiveMembers.map(
                              (m) => _buildMemberCard(context, ref, m, m.role == 'owner')),
                        ],

                        // Pending invitations section
                        if (pendingMembers.isNotEmpty) ...[
                          if (sortedActiveMembers.isNotEmpty)
                            const SizedBox(height: 32.0),
                          Text(
                            'Invitations en attente (${pendingMembers.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ...pendingMembers.map(
                              (m) => _buildMemberCard(context, ref, m, false)),
                        ],

                        // Empty state
                        if (filteredMembers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 48,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun membre trouvé',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

      // FAB to invite a new member
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            builder: (ctx) => InviteMemberModal(
              onInvite: (email, role) async {
                await viewModel.inviteMember(email, role);
              },
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  /// Builds a single member card with role badge and action menu.
  Widget _buildMemberCard(
      BuildContext context, WidgetRef ref, dynamic member, bool isOwner) {
    final theme = Theme.of(context);
    final viewModel =
        ref.read(manageMembersViewModelProvider(projectId).notifier);
    final badgeColor = _roleBadgeColor(member.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE6E4E6),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2F3035),
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(member.avatarUrl),
            backgroundColor: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  member.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB1B1B1),
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _roleLabel(member.role),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (member.isPending) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF87941).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                              color: const Color(0xFFF87941).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'En attente',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFF87941),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Owner cannot be modified or removed.
          if (!isOwner)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant),
              onSelected: (value) {
                if (value == 'remove') {
                  _confirmRemoveMember(context, viewModel, member);
                } else {
                  viewModel.updateMemberRole(member.id, value);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'admin', child: Text('Administrateur')),
                const PopupMenuItem(value: 'member', child: Text('Membre')),
                const PopupMenuItem(
                    value: 'viewer', child: Text('Observateur')),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'remove',
                  child: Text('Retirer du projet',
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before removing a member.
  void _confirmRemoveMember(BuildContext context,
      ManageMembersViewModel viewModel, dynamic member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer le membre'),
        content: Text(
          'Êtes-vous sûr de vouloir retirer ${member.name} du projet ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              viewModel.removeMember(member.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}
