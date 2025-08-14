import 'package:flutter/material.dart';
import '../widgets/material_selection_screen.dart';

class CetakScreen extends StatelessWidget {
  const CetakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Bahan Cetak'),
        backgroundColor: const Color(0xFF069494),
        foregroundColor: Colors.white,
      ),
      body: const MaterialSelectionScreen(),
    );
  }
}
