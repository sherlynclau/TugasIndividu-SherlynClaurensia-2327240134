import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

// Variabel global untuk mengontrol tema (Dark/Light Mode)
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
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Catatan Kuliah',
          // TEMA TERANG (Light Mode)
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 213, 233, 255), 
              foregroundColor: Colors.black, 
              elevation: 0
            ),
          ),
          // TEMA GELAP (Dark Mode)
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF), 
              brightness: Brightness.dark
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212), 
              foregroundColor: Colors.white, 
              elevation: 0
            ),
          ),
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}