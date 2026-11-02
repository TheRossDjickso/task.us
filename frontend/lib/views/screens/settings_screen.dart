import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/inbox_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'login_screen.dart';

// Settings screen showcasing user profile, notifications, account, and support.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.valueOrNull;
    final theme = Theme.of(context);

    // Diag Plus strict palette
    const brilliance = Color(0xFFFDFCFC);
    const nightBlack = Color(0xFF2F3035);
    const palladium = Color(0xFFB1B1B1);
    const preciousPersimmon = Color(0xFFF87941);
    const violetEssence = Color(0xFFE6E4E6);

    return Scaffold(
      backgroundColor: brilliance,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: nightBlack,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Manage your account and app preferences.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palladium,
                ),
              ),
              const SizedBox(height: 32.0),

              _buildSectionCard(
                title: 'PROFILE',
                child: Row(
                  children: [
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: violetEssence, width: 2),
                        color: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                            ? preciousPersimmon.withOpacity(0.1)
                            : null,
                        image: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                          ? Center(
                              child: Text(
                                (user?.fullName.isNotEmpty ?? false)
                                    ? user!.fullName[0].toUpperCase()
                                    : 'U',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: preciousPersimmon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Utilisateur',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: nightBlack,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palladium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // NOTIFICATIONS Section
              _buildSectionCard(
                title: 'NOTIFICATIONS',
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Direct messages and updates',
                      value: settingsState.pushNotificationsEnabled,
                      onChanged: (val) =>
                          settingsNotifier.togglePushNotifications(),
                    ),
                    const SizedBox(height: 16.0),
                    _buildSwitchTile(
                      title: 'Reminders',
                      subtitle: 'Daily goal tracking alerts',
                      value: settingsState.remindersEnabled,
                      onChanged: (val) => settingsNotifier.toggleReminders(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // ACCOUNT Section
              _buildSectionCard(
                title: 'ACCOUNT',
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.lock_outline,
                      title: 'Security & Privacy',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8.0),
                    _buildActionTile(
                      icon: Icons.storage_outlined,
                      title: 'Data & Storage',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // HELP & SUPPORT Section
              _buildSectionCard(
                title: 'HELP & SUPPORT',
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8.0),
                    _buildActionTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      trailingIcon: Icons.open_in_new,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(authViewModelProvider.notifier).logout();

                    // Clear all user-dependent state to prevent
                    // stale data from leaking to the next session.
                    ref.invalidate(projectViewModelProvider);
                    ref.invalidate(inboxViewModelProvider);

                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: violetEssence.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),

              // Footer
              Center(
                child: Text(
                  'Momentum Version 2.4.1 (Stable)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: palladium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required Widget child,
  }) {
    const preciousPersimmon = Color(0xFFF87941);
    const violetEssence = Color(0xFFE6E4E6);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: violetEssence.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x052F3035),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: preciousPersimmon,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  letterSpacing: 1.2,
                ),
              ),
              if (actionText != null && onActionTap != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: preciousPersimmon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20.0),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    const nightBlack = Color(0xFF2F3035);
    const palladium = Color(0xFFB1B1B1);
    const preciousPersimmon = Color(0xFFF87941);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: nightBlack,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: const TextStyle(
                  color: palladium,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: preciousPersimmon,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: palladium.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    IconData trailingIcon = Icons.chevron_right,
    required VoidCallback onTap,
  }) {
    const nightBlack = Color(0xFF2F3035);
    const palladium = Color(0xFFB1B1B1);
    const preciousPersimmon = Color(0xFFF87941);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: preciousPersimmon,
              size: 24.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: nightBlack,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              trailingIcon,
              color: palladium,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
