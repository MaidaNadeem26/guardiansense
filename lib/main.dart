// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// Global theme notifier - jahan se bhi is value ko change karo, poori app update ho jayegi
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // Light Theme
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            primaryColor: const Color(0xFF2F5CFF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F5CFF),
              brightness: Brightness.light,
            ),
          ),

          // Dark Theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF2F5CFF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F5CFF),
              brightness: Brightness.dark,
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}