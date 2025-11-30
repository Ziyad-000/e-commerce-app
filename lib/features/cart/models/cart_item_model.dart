import 'package:cloud_firestore/cloud_firestore.dart';
import '../../products/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final String? selectedSize;
  final int? selectedColor;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id']?.toString() ?? '',
      product: ProductModel.fromMap(map['product'] as Map<String, dynamic>),
      quantity: map['quantity']?.toInt() ?? 1,
      selectedSize: map['selectedSize']?.toString(),
      selectedColor: map['selectedColor']?.toInt(),
      addedAt: map['addedAt'] != null
          ? (map['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
