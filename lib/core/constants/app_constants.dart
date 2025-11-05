import 'package:flutter/material.dart';

/// Global color palette for the app. Update values here to theme the whole app.
class ColorConstants {
  // Brand colors
  static const Color primary = Color(0xFF49113C);
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Colors.white;
  static const Color secondary2 = Color(0xFF6C6C6C); // subtle text

  static const Color background = Color(0xFFF7F2FA);
  static const Color onBackground = Color(0xFF1D1B20);

  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF1D1B20);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Colors.white;

  // Misc
  static const Color borderTextFormField = Color(0xFFE0E0E0);
  static const Color black = Colors.black;
}

/// App-wide spacing, radius and durations.
class AppConstants {
  // Spacing
  static const double gapXS = 4;
  static const double gapS = 8;
  static const double gapM = 16;
  static const double gapL = 24;
  static const double gapXL = 32;

  // Radius
  static const double radiusS = 6;
  static const double radiusM = 12;
  static const double radiusL = 16;

  // Animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}
