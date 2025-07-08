import 'package:flutter/material.dart';
import 'colors.dart';

final lightMode = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundPageColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
    background: backgroundPageColor,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: textColor,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: textColor),
    bodyLarge: TextStyle(color: textColor),
    titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: textColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: primaryColor,
  ),
);
