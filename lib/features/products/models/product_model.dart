class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final String? size;
  final int? quantity;
  final double? discount;
  final double? finalPrice;
  final int? color;
  final String category;
  final List<String>? sizes;
  final int? stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.rating,
    this.reviewCount = 0,
    required this.category,
    this.isFeatured = false,
    this.size,
    this.color,
    this.quantity,
    this.discount,
    this.finalPrice,
    this.sizes,
    this.stock,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'description': description});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'price': price});
    if (oldPrice != null) result.addAll({'oldPrice': oldPrice});
    result.addAll({'rating': rating});
    result.addAll({'reviewCount': reviewCount});
    result.addAll({'category': category});
    result.addAll({'isFeatured': isFeatured});
    if (size != null) result.addAll({'size': size});
    if (color != null) result.addAll({'color': color});
    if (quantity != null) result.addAll({'Quantity': quantity});
    if (discount != null) result.addAll({'discount': discount});
    if (finalPrice != null) result.addAll({'finalPrice': finalPrice});
    if (sizes != null) result.addAll({'sizes': sizes});
    if (stock != null) result.addAll({'stock': stock});

    return result;
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    try {
      double productPrice = 0.0;
      double? productOldPrice;

      if (map['finalPrice'] != null) {
        productPrice = _toDouble(map['finalPrice']);

        if (map['discount'] != null && _toDouble(map['discount']) > 0) {
          double discountValue = _toDouble(map['discount']);
          productOldPrice = productPrice / (1 - (discountValue / 100));
        }
      } else if (map['price'] != null) {
        productPrice = _toDouble(map['price']);
        productOldPrice = map['oldPrice'] != null
            ? _toDouble(map['oldPrice'])
            : null;
      }

      int? colorValue;
      if (map['color'] != null) {
        if (map['color'] is List) {
          final colorList = map['color'] as List;
          if (colorList.isNotEmpty) {
            colorValue = _toInt(colorList[0]);
          }
        } else {
          colorValue = _toInt(map['color']);
        }
      }

      // ← Parse sizes
      List<String>? sizesList;
      if (map['sizes'] != null) {
        if (map['sizes'] is List) {
          sizesList = List<String>.from(map['sizes']);
        }
      }

      return ProductModel(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? '',
        price: productPrice,
        oldPrice: productOldPrice,
        rating: map['rating'] != null ? _toDouble(map['rating']) : 0.0,
        reviewCount: map['reviewCount'] != null
            ? _toInt(map['reviewCount'])
            : 0,
        category: map['category']?.toString() ?? '',
        isFeatured: map['isFeatured'] == true,
        size: map['size']?.toString(),
        color: colorValue,
        quantity: map['Quantity'] != null ? _toInt(map['Quantity']) : null,
        discount: map['discount'] != null ? _toDouble(map['discount']) : null,
        finalPrice: map['finalPrice'] != null
            ? _toDouble(map['finalPrice'])
            : null,
        sizes: sizesList,
        stock: map['stock'] != null ? _toInt(map['stock']) : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
