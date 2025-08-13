import 'package:flutter/material.dart';

class AntarScreen extends StatelessWidget {
  const AntarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antar'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: const Center(child: Text('Halaman Antar')),
    );
  }
}
