import 'package:ecommerce_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../features/products/models/product_model.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardTheme = Theme.of(context).cardTheme;

    final bool onSale =
        product.oldPrice != null && product.oldPrice! > product.price;
    final int discountPercentage = onSale
        ? (((product.oldPrice! - product.price) / product.oldPrice!) * 100)
              .round()
        : 0;

    return InkWell(
      onTap: () {
        print('hello');
        Navigator.pushNamed(
          context,
          AppRoutes.productDetailsRoute,
          arguments: product,
        );
        //Navigator.pushNamed(context, AppRoutes.productDetailsRoute, arguments: product.id);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: cardTheme.color,
        elevation: cardTheme.elevation,
        shape: cardTheme.shape,
        child: SizedBox(
          width: 180,
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
                      return const SizedBox(
                        height: 150,
                        child: Center(child: Icon(Icons.error)),
                      );
                    },
                  ),
                  if (onSale)
                    Positioned(
                      top: AppConstants.paddingM,
                      left: AppConstants.paddingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius / 2,
                          ),
                        ),
                        child: Text(
                          '-$discountPercentage%',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.accentForeground,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: AppConstants.paddingM,
                    right: AppConstants.paddingM,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surface.withOpacity(0.7),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        color: AppColors.foreground,
                        iconSize: 20,
                        onPressed: () {},
                      ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        Text(
                          product.rating.toString(),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                        ),
                        if (onSale)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppConstants.paddingM,
                            ),
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
      ),
    );
  }
}
