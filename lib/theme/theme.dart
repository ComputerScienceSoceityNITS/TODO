import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFCAF0F8), // Light blue
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0077B6),
      // Ocean Blue
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
      hintStyle: TextStyle(color: Colors.black54),
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    // checkboxTheme: CheckboxThemeData(
    //   fillColor: MaterialStateProperty.all(Color(0xFF0077B6)),
    // ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFF0077B6)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E2F),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C3C),
      border: OutlineInputBorder(),
      hintStyle: TextStyle(color: Colors.white54),
    ),
    cardColor: const Color(0xFF2C2C3C),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      // bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
      labelSmall: TextStyle(
        color: Colors.redAccent,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.redAccent,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      // fillColor: MaterialStateProperty.all(Color(0xFF82AAFF)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFF0077B6)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E2F),
        foregroundColor: Colors.white,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Color(0xFF82AAFF)),
      trackColor: MaterialStateProperty.all(Color(0xFF3949AB)),
    ),
  );
}
