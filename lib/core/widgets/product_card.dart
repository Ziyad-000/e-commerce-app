import 'package:ecommerce_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/products/models/product_model.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardTheme = Theme.of(context).cardTheme;

    final bool onSale = product.discount != null && product.discount! > 0;
    final int discountPercentage = onSale ? product.discount!.toInt() : 0;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetailsRoute,
          arguments: product,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: cardTheme.color,
        elevation: cardTheme.elevation,
        shape: cardTheme.shape,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.surface2,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.mutedForeground,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                if (onSale)
                  Positioned(
                    top: AppConstants.paddingM,
                    left: AppConstants.paddingM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.destructive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discountPercentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: AppConstants.paddingM,
                  right: AppConstants.paddingM,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favProvider, child) {
                      final isFav = favProvider.isFavorite(product.id);
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                          ),
                          color: isFav ? Colors.red : Colors.black,
                          onPressed: () {
                            if (isFav) {
                              favProvider.removeFavoriteProduct(product.id);
                            } else {
                              favProvider.addFavoriteProduct(product);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: AppColors.warning),
                        itemCount: 5,
                        itemSize: 14.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      if (product.oldPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '\$${product.oldPrice!.toStringAsFixed(2)}',
                            style: textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
