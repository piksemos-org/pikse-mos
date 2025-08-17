import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piksel_mos/main.dart';
import 'package:piksel_mos/piksel/desain/brief/brief_screen.dart';
import 'package:piksel_mos/piksel/desain/models/brief_data_model.dart';

class DesainScreen extends StatelessWidget {
  const DesainScreen({super.key});

  Future<List<dynamic>> _fetchDesignCategories() async {
    try {
      return await supabase
          .from('design_categories')
          .select()
          .order('name', ascending: true);
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Desain'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchDesignCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada kategori ditemukan'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final category = snapshot.data![index];
              return Card(
                elevation: 4,
                child: InkWell(
                onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (context) => BriefDataModel(),
                          child: const BriefScreen(),
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
