import 'package:ecommerce_app/features/products/views/widgets/product_card.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/product_model.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback onSeeAll;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(60, 32),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Products Grid
          if (products.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No products available',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length > 6 ? 6 : products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
        ],
      ),
    );
  }
}
