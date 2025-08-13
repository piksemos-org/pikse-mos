import 'package:flutter/material.dart';

class KamuScreen extends StatelessWidget {
  const KamuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Kamu'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: const Center(child: Text('Halaman Profil')),
    );
  }
}
