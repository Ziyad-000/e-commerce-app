import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductsService _service = ProductsService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get allProducts => _products;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ProductModel> get discountedProducts {
    return _products
        .where((p) => p.discount != null && p.discount! > 0)
        .toList();
  }

  void listenToProducts() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _service.watchAllProducts().listen(
      (products) {
        _products = products;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load products';
        notifyListeners();
      },
    );
  }

  void listenToFeaturedProducts() {
    _service.watchFeaturedProducts().listen((products) {
      _featuredProducts = products;
      notifyListeners();
    });
  }

  void fetchAllProducts() {
    listenToProducts();
  }

  void fetchFeaturedProducts() {
    listenToFeaturedProducts();
  }

  void fetchDiscountedProducts() {
    notifyListeners();
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _service.watchByCategory(category);
  }

  Future<ProductModel?> getProductById(String productId) {
    return _service.getProductById(productId);
  }

  Stream<List<ProductModel>> searchProducts(String query) {
    return _service.searchProducts(query);
  }
}
