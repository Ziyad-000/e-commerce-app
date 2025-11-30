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
      context.read<CategoryProvider>().listenToCategories();
      context.read<ProductProvider>().listenToFeaturedProducts();
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
                const Text(
                  'Shop by Category',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
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
                            childAspectRatio: 0.75,
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: category.imageUrl.isNotEmpty
                                        ? Image.network(
                                            category.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: AppColors.surface2,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.category,
                                                        size: 40,
                                                        color: AppColors
                                                            .mutedForeground,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: AppColors.surface2,
                                            child: const Center(
                                              child: Icon(
                                                Icons.category,
                                                size: 40,
                                                color:
                                                    AppColors.mutedForeground,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          color: AppColors.foreground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${category.productCount} items',
                                        style: const TextStyle(
                                          color: AppColors.mutedForeground,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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

                // Trending Section
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
                    final trendingProducts = productProvider.featuredProducts
                        .take(3)
                        .toList();

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
                          'Featured items',
                          Colors.green,
                          () {},
                        ),
                        const SizedBox(height: 12),
                        _buildTrendingItem(
                          'Formal Wear',
                          'Best sellers',
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
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
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
