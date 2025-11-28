import '../../products/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? selectedSize;
  final int? selectedColor;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }
}
