import 'package:flutter/material.dart';
import 'package:piksel_mos/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait for a short period to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (!mounted) return;

    if (session != null) {
      try {
        final userId = supabase.auth.currentUser!.id;
        final data = await supabase
            .from('users')
            .select('role')
            .eq('id', userId)
            .single();
        userRole.value = data['role'] as String?;
      } catch (e) {
        // Handle potential errors, e.g., user not found in 'users' table
        userRole.value = null; // Default to no role on error
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenBoarding = prefs.getBool('hasSeenBoarding') ?? false;

      if (!mounted) return;

      if (hasSeenBoarding) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.of(context).pushReplacementNamed('/boarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
