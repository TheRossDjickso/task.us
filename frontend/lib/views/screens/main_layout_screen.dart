import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/inbox_viewmodel.dart';
import '../../viewmodels/navigation_viewmodel.dart';
import '../widgets/bottom_nav_bar.dart';
import 'notifications_screen.dart';
import 'project_list_screen.dart';
import 'search_screen.dart';
import 'inbox_screen.dart';
import 'settings_screen.dart';

// Main container that structures the application layout.
// Joins the top bar, the main content according to the active tab
// and the custom bottom navigation bar.
class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(navigationProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = ref.watch(navigationProvider);
    final theme = Theme.of(context);

    ref.listen<int>(navigationProvider, (previous, next) {
      if (next != previous && _pageController.hasClients) {
        final currentPage = _pageController.page?.round();
        if (currentPage != next) {
          _pageController.jumpToPage(next);
        }
      }
    });

    return Scaffold(
      // Custom top bar that imitates the HTML header.
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        titleSpacing: 16.0,
        title: Image.asset(
          'images/logo-1024.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(unreadNotificationsCountProvider);
              final iconButton = IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onBackground,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              );

              if (count == 0) {
                return iconButton;
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  iconButton,
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF87941),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Color(0xFFFDFCFC),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
        children: const [
          ProjectListScreen(),
          SearchScreen(),
          InboxScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

