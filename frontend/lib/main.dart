import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/navigation.dart';
import 'utils/theme.dart';
import 'views/screens/main_layout_screen.dart';
import 'views/screens/login_screen.dart';
import 'viewmodels/auth_viewmodel.dart';

// Entry point of the application.
// Initializes the Riverpod configuration with ProviderScope and loads
// the unified visual design under the centralized theme.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Main widget that defines the global properties of the application,
// such as the system title, the palette visual theme, and the home screen.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      title: 'Task.us',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: diagPlusTheme,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const MainLayoutScreen();
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF87941),
            ),
          ),
        ),
        error: (err, stack) => const LoginScreen(),
      ),
    );
  }
}
