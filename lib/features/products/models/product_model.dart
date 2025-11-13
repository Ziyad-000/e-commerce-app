class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final double rating;
  final String category;
  final bool isFeatured;
  final String? size;
  final int? color;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.category,
    this.isFeatured = false,
    this.size,
    this.color,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'description': description});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'price': price});
    if (oldPrice != null) {
      result.addAll({'oldPrice': oldPrice});
    }
    result.addAll({'rating': rating});
    result.addAll({'category': category});
    result.addAll({'isFeatured': isFeatured});
    if (size != null) {
      result.addAll({'size': size});
    }
    if (color != null) {
      result.addAll({'color': color});
    }

    return result;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      oldPrice: map['oldPrice']?.toDouble(),
      rating: map['rating']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      size: map['size'],
      color: map['color']?.toInt(),
    );
  }
}
