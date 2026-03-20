// lib/models/product_model.dart

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> ingredients;
  final List<String> warnings;
  final String audioUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.warnings,
    this.audioUrl = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:          json['product_id']?.toString() ?? json['id']?.toString() ?? '',
    name:        json['name']?.toString() ?? 'Unknown Product',
    category:    json['category']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    warnings:    List<String>.from(json['warnings'] ?? []),
    audioUrl:    json['audio_url']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'category': category,
    'description': description,
    'ingredients': ingredients, 'warnings': warnings,
    'audio_url': audioUrl,
  };

  String get primaryAudio {
    final b = StringBuffer();
    b.write('$name. ');
    if (category.isNotEmpty) b.write('Category: $category. ');
    if (description.isNotEmpty) b.write(description);
    return b.toString();
  }

  String get fullAudio {
    final b = StringBuffer();
    b.write(primaryAudio);
    if (ingredients.isNotEmpty) b.write(' Ingredients: ${ingredients.join(', ')}. ');
    if (warnings.isNotEmpty)    b.write(' Warnings: ${warnings.join('. ')}.');
    return b.toString();
  }
}