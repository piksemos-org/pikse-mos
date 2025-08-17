import 'dart:async'; // Import untuk StreamSubscription
import 'package:app_links/app_links.dart'; // Import package app_links
import 'package:flutter/material.dart';
import 'package:piksel_mos/autentification/login_screen.dart';
import 'package:piksel_mos/autentification/regster_screen.dart';
import 'package:piksel_mos/boarding/boarding_screen.dart';
import 'package:piksel_mos/information/message_screen.dart';
import 'package:piksel_mos/information/notification_screen.dart';
import 'package:piksel_mos/piksel/kamu/storage_screen.dart';
import 'package:piksel_mos/piksel/main_screen.dart';
import 'package:piksel_mos/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yltxsucpzthnzchziakc.supabase.co', // Keep this line unchanged
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsdHhzdWNwenRobnpjaHppYWtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwOTQxNDAsImV4cCI6MjA3MDY3MDE0MH0.06652ebnPe0k6n9qVf4CI8x1OORUVaWnjjrLbCPcBq4',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
final ValueNotifier<String?> userRole = ValueNotifier(null);

// PERBAIKAN: MyApp diubah menjadi StatefulWidget untuk menangani Stream
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Memulai listener untuk deep link
    _initDeepLinks();
  }

  @override
  void dispose() {
    // PERBAIKAN: Membatalkan listener saat aplikasi ditutup
    _linkSubscription?.cancel();
    super.dispose();
  }

  // PERBAIKAN: Fungsi baru untuk menangani deep links dengan metode Stream
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Berlangganan (listen) ke stream untuk setiap link yang masuk
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      // Anda bisa menambahkan logika navigasi di sini berdasarkan link yang masuk
      // Contoh: Buka halaman detail jika linknya adalah pikselmos://details/123
      print('Menerima link: $uri');
      //
      // if (uri.host == 'details') {
      //   final id = uri.pathSegments.first;
      //   // Navigator.push(...);
      // }
    });
  }

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
        '/main': (context) => MainScreen(),
        '/storage': (context) => const StorageScreen(),
        '/notifications': (context) => const NotificationScreen(),
'/messages': (context) => MessageScreen(),
      },
    );
  }
}
