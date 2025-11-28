import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductsService _productsService = ProductsService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _discountedProducts = [];
  List<ProductModel> _categoryProducts = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get discountedProducts => _discountedProducts;
  List<ProductModel> get categoryProducts => _categoryProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // جلب كل المنتجات
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _productsService.getAllProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products';
      notifyListeners();
    }
  }

  // جلب المنتجات المميزة
  Future<void> fetchFeaturedProducts() async {
    try {
      _featuredProducts = await _productsService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
    }
  }

  // جلب منتجات بخصم
  Future<void> fetchDiscountedProducts() async {
    try {
      _discountedProducts = await _productsService.getDiscountedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching discounted products: $e');
    }
  }

  // جلب منتجات حسب الفئة
  Future<void> fetchProductsByCategory(String categoryName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryProducts = await _productsService.getProductsByCategory(
        categoryName,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products';
      notifyListeners();
    }
  }

  // بحث في المنتجات
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _productsService.searchProducts(query);
  }
}
