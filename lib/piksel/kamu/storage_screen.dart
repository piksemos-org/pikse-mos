import 'package:flutter/material.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penyimpanan Desain'), elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/200/300?random=$index',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
