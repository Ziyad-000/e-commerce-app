import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/add_to_cart_bottom_sheet.dart';
import '../../../../core/widgets/universal_image.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../favorites/providers/favorites_provider.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;
  int? selectedColor;
  int quantity = 1;

  final List<Color> colors = [Colors.black, Colors.white, Colors.grey];

  @override
  Widget build(BuildContext context) {
    final bool onSale =
        widget.product.discount != null && widget.product.discount! > 0;
    final int discountPercentage = onSale
        ? widget.product.discount!.toInt()
        : 0;
    final availableSizes = widget.product.sizes ?? ['XS', 'S', 'M', 'L', 'XL'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    UniversalImage(
                      imageUrl: widget.product.imageUrl,
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        height: 400,
                        color: AppColors.surface2,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),

                    // Back Button
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Favorite Button
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favProvider, child) {
                          final isFav = favProvider.isFavorite(
                            widget.product.id,
                          );
                          return CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.black,
                              ),
                              onPressed: () {
                                if (isFav) {
                                  favProvider.removeFavoriteProduct(
                                    widget.product.id,
                                  );
                                } else {
                                  favProvider.addFavoriteProduct(
                                    widget.product,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Discount Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                color: AppColors.foreground,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (onSale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.destructive,
                                borderRadius: BorderRadius.circular(12),
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
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.foreground,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (widget.product.oldPrice != null)
                            Text(
                              '\$${widget.product.oldPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product.rating}',
                            style: const TextStyle(
                              color: AppColors.foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${widget.product.reviewCount} reviews)',
                            style: const TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        widget.product.description.isNotEmpty
                            ? widget.product.description
                            : 'Made from premium cotton blend for ultimate comfort',
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Size Selector
                      const Text(
                        'Size',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: availableSizes.map((size) {
                          final isSelected = selectedSize == size;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.foreground
                                    : AppColors.surface2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.foreground
                                      : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.background
                                        : AppColors.foreground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Color Selector
                      const Text(
                        'Color',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(colors.length, (index) {
                          final isSelected = selectedColor == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedColor = index;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.border,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Quantity Selector
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: AppColors.foreground,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                color: AppColors.foreground,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.foreground,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        for (int i = 0; i < quantity; i++) {
                          context.read<CartProvider>().addToCart(
                            widget.product,
                            size: selectedSize,
                            color: selectedColor,
                          );
                        }
                        AddToCartBottomSheet.show(
                          context,
                          product: widget.product,
                          selectedSize: selectedSize,
                          selectedColor: selectedColor,
                          quantity: quantity,
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
