import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/pages/splash/splash_screen.dart';
import 'package:test1/prov_counter.dart';
import 'package:test1/theme/theme.dart';

import 'theme/theme_provider.dart';

void main() {
  runApp(
    // ChangeNotifierProvider(create: (_) => CounterProvider(), child: MyApp()),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
