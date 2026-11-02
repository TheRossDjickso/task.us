import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/inbox_viewmodel.dart';
import '../../viewmodels/navigation_viewmodel.dart';

// Custom bottom navigation bar.
// Replicates the web application design with subtle animations,
// capsule shapes for active elements, and the color scheme.
class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(navigationProvider);
    final navNotifier = ref.read(navigationProvider.notifier);
    final theme = Theme.of(context);

    // Watch the unread invitation count to drive the badge reactively.
    final unreadCount = ref.watch(unreadInviteCountProvider);

    return Container(
      height: 76.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2F3035),
            blurRadius: 12.0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.folder_outlined,
              label: 'Projects',
              isActive: activeIndex == 0,
              onTap: () => navNotifier.setIndex(0),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.search_outlined,
              label: 'Search',
              isActive: activeIndex == 1,
              onTap: () => navNotifier.setIndex(1),
            ),
            // Inbox tab with reactive unread badge.
            _buildNavItem(
              context: context,
              icon: Icons.inbox_outlined,
              label: 'Inbox',
              isActive: activeIndex == 2,
              badgeCount: unreadCount,
              onTap: () => navNotifier.setIndex(2),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              isActive: activeIndex == 3,
              onTap: () => navNotifier.setIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  // Builds an individual navigation item.
  // [badgeCount] — when > 0, renders a small pill badge over the icon.
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);

    // State colors.
    final activeBg = theme.colorScheme.secondary.withValues(alpha: 0.2);
    final activeContent = theme.colorScheme.onSecondary;
    final inactiveContent = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon wrapped in a Stack so the badge can be overlaid.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeContent : inactiveContent,
                  size: 24.0,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -6.0,
                    right: -8.0,
                    child: _buildBadge(badgeCount),
                  ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive ? activeContent : inactiveContent,
                fontSize: 10.0,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the small circular badge with the unread count.
  /// Displays "9+" when the count exceeds 9 to keep the badge compact.
  Widget _buildBadge(int count) {
    final label = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      decoration: BoxDecoration(
        // Precious Persimmon — primary accent from the Diag Plus palette.
        color: const Color(0xFFF87941),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          // Brilliance — used as border to lift the badge off the icon.
          color: const Color(0xFFFDFCFC),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          // Brilliance — high contrast text on orange background.
          color: Color(0xFFFDFCFC),
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }
}

