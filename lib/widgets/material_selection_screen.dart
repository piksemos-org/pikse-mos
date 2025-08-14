import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/print_material.dart';

class MaterialSelectionScreen extends StatefulWidget {
  const MaterialSelectionScreen({super.key});

  @override
  State<MaterialSelectionScreen> createState() =>
      _MaterialSelectionScreenState();
}

class _MaterialSelectionScreenState extends State<MaterialSelectionScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<List<PrintMaterial>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _fetchMaterials();
  }

  Future<List<PrintMaterial>> _fetchMaterials() async {
    try {
      final response = await _supabase
          .from('print_materials')
          .select('id, name, category, variants');

      return (response as List)
          .map((item) => PrintMaterial.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat bahan: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PrintMaterial>>(
      future: _materialsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final material = snapshot.data![index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  material.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(material.category),
                children: material.variants
                    .map(
                      (variant) => ListTile(
                        title: Text(variant.name),
                        trailing: Text(
                          'Rp${variant.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () {
                          // Handle variant selection
                        },
                      ),
                    )
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}
