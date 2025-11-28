import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'Men';

  @override
  void initState() {
    super.initState();
    // جلب المنتجات عند فتح الصفحة
    Future.microtask(() async {
      final provider = context.read<ProductProvider>();
      await provider.fetchAllProducts();
      await provider.fetchFeaturedProducts();
      await provider.fetchDiscountedProducts();

      // Debug فقط
      debugPrint('🔥 Total products: ${provider.allProducts.length}');
      debugPrint('🔥 Featured: ${provider.featuredProducts.length}');
      debugPrint('🔥 Discounted: ${provider.discountedProducts.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // لو بيحمّل
          if (productProvider.isLoading &&
              productProvider.allProducts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          // لو فيه خطأ
          if (productProvider.errorMessage != null &&
              productProvider.allProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.destructive),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.fetchAllProducts();
                      productProvider.fetchFeaturedProducts();
                      productProvider.fetchDiscountedProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Special Offers Banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Special Offers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Up to 50% off on selected items',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.destructive,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Shop Now'),
                      ),
                    ],
                  ),
                ),

                // 2. Categories Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryTab('Men'),
                        _buildCategoryTab('Women'),
                        _buildCategoryTab('Kids'),
                        _buildCategoryTab('New'),
                        _buildCategoryTab('Sale'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Recommended for you
                ProductSection(
                  title: 'Recommended for you',
                  products: productProvider.allProducts.take(6).toList(),
                  onSeeAll: () {},
                ),

                const SizedBox(height: 24),

                // 4. On Sale
                ProductSection(
                  title: 'On Sale',
                  products: productProvider.discountedProducts.take(6).toList(),
                  onSeeAll: () {},
                ),

                const SizedBox(height: 24),

                // 5. Featured Products
                ProductSection(
                  title: 'Featured Products',
                  products: productProvider.featuredProducts.take(6).toList(),
                  onSeeAll: () {},
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(String title) {
    final isSelected = selectedCategory == title;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.foreground : AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.background : AppColors.foreground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
