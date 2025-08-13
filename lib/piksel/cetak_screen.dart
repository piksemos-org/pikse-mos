import 'package:flutter/material.dart';

class CetakScreen extends StatelessWidget {
  const CetakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cetak'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: const Center(child: Text('Halaman Cetak')),
    );
  }
}
