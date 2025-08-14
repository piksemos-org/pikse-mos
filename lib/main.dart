import 'package:flutter/material.dart';
import 'package:piksel_mos/autentification/login_screen.dart';
import 'package:piksel_mos/autentification/regster_screen.dart';
import 'package:piksel_mos/boarding/boarding_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:piksel_mos/piksel/main_screen.dart';
import 'package:piksel_mos/piksel/upload_screen.dart';
import 'package:piksel_mos/piksel/kamu/storage_screen.dart';
import 'package:piksel_mos/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Global ValueNotifier to hold the user's role.
final ValueNotifier<String?> userRole = ValueNotifier(null);

void main() async {
  // Tambahkan 'async' di sini
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ada untuk inisialisasi

  await Supabase.initialize(
    // Inisialisasi Supabase
    url: 'https://yltxsucpzthnzchziakc.supabase.co', // Paste URL Anda di sini
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsdHhzdWNwenRobnpjaHppYWtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwOTQxNDAsImV4cCI6MjA3MDY3MDE0MH0.06652ebnPe0k6n9qVf4CI8x1OORUVaWnjjrLbCPcBq4', // Paste anon key Anda di sini
  );

  runApp(const MyApp());
}

// Variabel global untuk akses mudah ke client Supabase
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piksel Mos',
      theme: ThemeData(
        primaryColor: const Color(0xFF069494),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF069494),
          primary: const Color(0xFF069494),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF069494), width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF069494),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF069494),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/boarding': (context) => const BoardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/upload': (context) => const UploadScreen(),
        '/storage': (context) => const StorageScreen(),
      },
    );
  }
}
