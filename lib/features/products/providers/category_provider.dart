import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  void listenToCategories() {
    _isLoading = true;
    notifyListeners();

    _service.getCategories().listen(
      (categories) {
        _categories = categories;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<CategoryModel?> getCategoryById(String categoryId) {
    return _service.getCategoryById(categoryId);
  }
}
