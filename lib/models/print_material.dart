class PrintMaterial {
  final String id;
  final String name;
  final String category;
  final List<MaterialVariant> variants;

  PrintMaterial({
    required this.id,
    required this.name,
    required this.category,
    required this.variants,
  });

  factory PrintMaterial.fromJson(Map<String, dynamic> json) {
    return PrintMaterial(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      variants: (json['variants'] as List)
          .map((v) => MaterialVariant.fromJson(v))
          .toList(),
    );
  }
}

class MaterialVariant {
  final String name;
  final double price;

  MaterialVariant({required this.name, required this.price});

  factory MaterialVariant.fromJson(Map<String, dynamic> json) {
    return MaterialVariant(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
