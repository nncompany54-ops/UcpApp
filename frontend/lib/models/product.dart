class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> allImages;
  final String companyName;
  final String? ingredients;
  final String? usage;
  final String? warnings;
  final String? skinType;
  final String? targetAudience;
  final String? productType;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.allImages,
    required this.companyName,
    this.ingredients,
    this.usage,
    this.warnings,
    this.skinType,
    this.targetAudience,
    this.productType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(json['images']);
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      imageUrl: imagesList.isNotEmpty ? imagesList[0] : '',
      allImages: imagesList,
      companyName: json['company'] != null ? json['company']['name'] : '',
      ingredients: json['ingredients'],
      usage: json['usage'],
      warnings: json['warnings'],
      skinType: json['skin_type'],
      targetAudience: json['target_audience'],
      productType: json['product_type'],
    );
  }
}
