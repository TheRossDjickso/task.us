import 'package:flutter/material.dart';

// The theme is centralized here to maintain visual consistency with the
// 'Task.us' design system (Palette Diag Plus).
// Primary and secondary colors are defined according to
// technical specifications to guarantee a premium design.
final ColorScheme diagPlusColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Precious Persimmon for main actions.
  primary: const Color(0xFFF87941),
  // No Way Rosé for secondary accents and badges.
  secondary: const Color(0xFFF9B095),
  // Brilliance for the main canvas and backgrounds.
  surface: const Color(0xFFFDFCFC),
  background: const Color(0xFFFDFCFC),
  // For error messages and critical warning states.
  error: Colors.redAccent,
  onError: const Color(0xFFFDFCFC),
  // Bright text on orange buttons.
  onPrimary: const Color(0xFFFDFCFC),
  // Night Black for text on the secondary color.
  onSecondary: const Color(0xFF2F3035),
  // Night Black for the main interface text.
  onSurface: const Color(0xFF2F3035),
  onBackground: const Color(0xFF2F3035),
  // Violet Essence for subtle borders and divider lines.
  outlineVariant: const Color(0xFFE6E4E6),
  // Palladium for secondary texts and support icons.
  onSurfaceVariant: const Color(0xFFB1B1B1),
);

// The global theme is defined with Inter typography.
final ThemeData diagPlusTheme = ThemeData(
  useMaterial3: true,
  colorScheme: diagPlusColorScheme,
  scaffoldBackgroundColor: diagPlusColorScheme.background,
  dividerColor: diagPlusColorScheme.outlineVariant,
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 48,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.02,
      color: Color(0xFF2F3035),
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
      color: Color(0xFF2F3035),
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2F3035),
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Color(0xFF2F3035),
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF2F3035),
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Color(0xFF2F3035),
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.05,
      color: Color(0xFF2F3035),
    ),
  ),
);
