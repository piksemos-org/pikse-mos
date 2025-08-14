import 'package:flutter/material.dart';
import '../widgets/material_selection_screen.dart';

class DesainScreen extends StatelessWidget {
  const DesainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Bahan Desain'),
        backgroundColor: const Color(0xFF069494),
        foregroundColor: Colors.white,
      ),
      body: const MaterialSelectionScreen(),
    );
  }
}
