import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/core/widgets/product_card.dart';
import 'package:ecommerce_app/features/products/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  final String categoryName;
  const ProductScreen({super.key, required this.categoryName});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductModel> productsList = [
    ProductModel(
      id: '0',
      name: 'Cotton T-shirt Regular Fit',
      description: 'Made from Premium cotton blend for ultimate comfort',
      imageUrl:
          'https://media.alshaya.com/adobe/assets/urn:aaid:aem:86ca5dfc-aa8a-4393-bbc2-a2faaa86ff53/as/EID-25c4e18f4568fa8617accca0a7a18c67fa969dce.jpg?preferwebp=true&width=1024&auto=webp ',
      price: 9.99,
      rating: 4.6,
      category: 'Shirts & Tops',
    ),
    ProductModel(
      id: '1',
      name: 'Cotton T-shirt Regular Fit',
      description: 'Made from Premium cotton blend for ultimate comfort',
      imageUrl:
          'https://media.alshaya.com/adobe/assets/urn:aaid:aem:86ca5dfc-aa8a-4393-bbc2-a2faaa86ff53/as/EID-25c4e18f4568fa8617accca0a7a18c67fa969dce.jpg?preferwebp=true&width=1024&auto=webp ',
      price: 29.99,
      rating: 4.8,
      category: 'Shirts & Tops',
    ),
    ProductModel(
      id: '2',
      name: 'Cotton T-shirt Regular Fit',
      description: 'Made from Premium cotton blend for ultimate comfort',
      imageUrl:
          'https://media.alshaya.com/adobe/assets/urn:aaid:aem:86ca5dfc-aa8a-4393-bbc2-a2faaa86ff53/as/EID-25c4e18f4568fa8617accca0a7a18c67fa969dce.jpg?preferwebp=true&width=1024&auto=webp ',
      price: 39.99,
      rating: 4.5,
      category: 'Shirts & Tops',
    ),
    ProductModel(
      id: '3',
      name: 'Cotton T-shirt Regular Fit',
      description: 'Made from Premium cotton blend for ultimate comfort',
      imageUrl:
          'https://media.alshaya.com/adobe/assets/urn:aaid:aem:86ca5dfc-aa8a-4393-bbc2-a2faaa86ff53/as/EID-25c4e18f4568fa8617accca0a7a18c67fa969dce.jpg?preferwebp=true&width=1024&auto=webp ',
      price: 49.99,
      rating: 4.7,
      category: 'Shirts & Tops',
    ),
  ];
  bool largeView = false;
  bool filterView = false;
  List<ProductModel> filteredProducts = [];
  late final TextEditingController productSearch;

  @override
  void initState() {
    productSearch = TextEditingController();
    filteredProducts = List.from(productsList);
    super.initState();
  }

  void filteredProductsShown(String value) {
    print(filteredProducts);
    filteredProducts = productsList.where((product) {
      final productName = product.name.toLowerCase();
      return value.isEmpty || productName.contains(value.toLowerCase());
    }).toList();
    print(filteredProducts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                      Text(
                        widget.categoryName,
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 20,
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
              TextField(
                onChanged: (value) {
                  setState(() {
                    filteredProductsShown(value);
                  });
                },
                onSubmitted: (value) => FocusScope.of(context).unfocus(),
                controller: productSearch,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                  hintText: widget.categoryName,
                  hintStyle: TextStyle(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 10),
              //filter bar,
              (!filterView)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            TextButton(
                              onPressed:
                                  // on favourite implement
                                  () {},
                              child: Text('Popular'),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surface2.withAlpha(
                                  200,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: theme.textTheme.labelLarge,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingXXL,
                                  vertical: AppConstants.paddingL,
                                ),
                              ),
                            ),
                            InkWell(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    filteredProducts.sort((product1, product2) {
                                      return product1.price.compareTo(
                                        product2.price,
                                      );
                                    });
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.surface2.withAlpha(
                                    200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  textStyle: theme.textTheme.labelLarge,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingXXL,
                                    vertical: AppConstants.paddingL,
                                  ),
                                ),
                                child: Text('Price: Low to High'),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  filteredProducts.sort((product1, product2) {
                                    return product2.price.compareTo(
                                      product1.price,
                                    );
                                  });
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surface2.withAlpha(
                                  200,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: theme.textTheme.labelLarge,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingXXL,
                                  vertical: AppConstants.paddingL,
                                ),
                              ),
                              child: Text('Price: High to Low'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  filteredProducts.sort((product1, product2) {
                                    return product1.rating.compareTo(
                                      product2.rating,
                                    );
                                  });
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surface2.withAlpha(
                                  200,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: theme.textTheme.labelLarge,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingXXL,
                                  vertical: AppConstants.paddingL,
                                ),
                              ),
                              child: Text('Rating'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(height: 5),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (largeView) ? 1 : 2,
                    childAspectRatio: (largeView) ? 1 : 0.6,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filteredProducts[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
