import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/pages/splash/splash_screen.dart';
import 'package:test1/prov_counter.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
