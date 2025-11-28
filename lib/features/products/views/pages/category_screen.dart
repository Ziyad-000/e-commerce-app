import 'package:ecommerce_app/core/routes/app_routes.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/providers/category_provider.dart';
import 'package:ecommerce_app/features/products/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchFeaturedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Shop by Category',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover your style',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),

                // Categories Grid
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      );
                    }

                    if (categoryProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              categoryProvider.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.destructive,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                categoryProvider.fetchCategories();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (categoryProvider.categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No categories available',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categoryProvider.categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productsRoute,
                              arguments: category.name,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(category.imageUrl),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),

                                // Text
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${category.CategoryNumber} items',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Trending Now Section
                const Text(
                  'Trending Now',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    final trendingProducts =
                        productProvider.featuredProducts.isEmpty
                        ? productProvider.allProducts.take(3).toList()
                        : productProvider.featuredProducts.take(3).toList();

                    if (trendingProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        _buildTrendingItem(
                          'Summer Collection',
                          '${trendingProducts.length} new items',
                          Colors.red,
                          () {},
                        ),
                        const SizedBox(height: 12),
                        _buildTrendingItem(
                          'Athletic Wear',
                          '23 items',
                          Colors.green,
                          () {},
                        ),
                        const SizedBox(height: 12),
                        _buildTrendingItem(
                          'Formal Wear',
                          '12 items',
                          Colors.orange,
                          () {},
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingItem(
    String title,
    String subtitle,
    Color indicatorColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mutedForeground,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
