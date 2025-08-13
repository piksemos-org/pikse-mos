import 'package:flutter/material.dart';

class DesainScreen extends StatelessWidget {
  const DesainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desain'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: const Center(child: Text('Halaman Desain')),
    );
  }
}
