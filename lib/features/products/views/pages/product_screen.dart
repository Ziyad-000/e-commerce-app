import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/views/widgets/product_card.dart';
import 'package:ecommerce_app/features/products/models/product_model.dart';
import 'package:ecommerce_app/features/products/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  final String categoryName;
  const ProductScreen({super.key, required this.categoryName});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool largeView = false;
  bool filterView = false;
  List<ProductModel> filteredProducts = [];
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProducts(String query, List<ProductModel> allProducts) {
    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((product) {
        final productName = product.name.toLowerCase();
        return productName.contains(query.toLowerCase());
      }).toList();
    }
  }

  void sortByPrice(bool ascending) {
    setState(() {
      filteredProducts.sort((a, b) {
        return ascending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price);
      });
    });
  }

  void sortByRating() {
    setState(() {
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      Text(
                        widget.categoryName,
                        style: const TextStyle(
                          color: AppColors.foreground,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            largeView = !largeView;
                          });
                        },
                        icon: const Icon(Icons.format_list_bulleted),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            filterView = !filterView;
                          });
                        },
                        icon: const Icon(Icons.filter_alt_outlined),
                      ),
                    ],
                  ),
                ],
              ),

              // Search Bar
              StreamBuilder<List<ProductModel>>(
                stream: productProvider.getProductsByCategory(
                  widget.categoryName,
                ),
                builder: (context, snapshot) {
                  final products = snapshot.data ?? [];

                  return TextField(
                    onChanged: (value) {
                      setState(() {
                        filterProducts(value, products);
                      });
                    },
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.mutedForeground,
                      ),
                      hintText: 'Search in ${widget.categoryName}',
                      hintStyle: const TextStyle(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Filter Bar
              if (!filterView)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('Popular', () {}),
                        _buildFilterButton('Price: Low to High', () {
                          sortByPrice(true);
                        }),
                        _buildFilterButton('Price: High to Low', () {
                          sortByPrice(false);
                        }),
                        _buildFilterButton('Rating', sortByRating),
                      ],
                    ),
                  ),
                ),

              // Products Grid
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: productProvider.getProductsByCategory(
                    widget.categoryName,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading products',
                          style: const TextStyle(color: AppColors.destructive),
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];

                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: AppColors.mutedForeground),
                        ),
                      );
                    }

                    if (filteredProducts.isEmpty &&
                        searchController.text.isEmpty) {
                      filteredProducts = List.from(products);
                    }

                    final displayProducts = searchController.text.isEmpty
                        ? products
                        : filteredProducts;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: largeView ? 1 : 2,
                        childAspectRatio: largeView ? 1 : 0.7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),

                      itemCount: displayProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: displayProducts[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surface2.withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}
