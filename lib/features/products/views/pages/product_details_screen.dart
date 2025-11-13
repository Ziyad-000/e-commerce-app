import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];
  final List<Color> colors = [Colors.black, Colors.white, Colors.grey];
  Color selectedColor = Colors.white;
  String selectedSize = 'XS';
  int qunatityNumber = 1;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Image.network(widget.product.imageUrl),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, style: textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Text(
                      '\$${widget.product.price}',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        Text(
                          widget.product.rating.toString(),
                          style: textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        color: const Color.fromARGB(124, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('Size', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Container(
                      width: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: sizes.map((size) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                            child: AnimatedContainer(
                              padding: EdgeInsets.all(16),
                              duration: Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: (selectedSize == size)
                                    ? Colors.white
                                    : Colors.grey[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: (selectedSize == size)
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    //Text('Color', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    DropdownMenu(
                      onSelected: (color) {
                        if (color != null) {
                          setState(() {
                            selectedColor = color;
                          });
                        }
                      },
                      label: Text('Select Product Color',style: TextStyle(color: Colors.white),),
                      enableFilter: true,
                      dropdownMenuEntries: <DropdownMenuEntry<Color>>[
                        DropdownMenuEntry(value: Colors.black, label: 'Black',labelWidget: Text('Black',style: TextStyle(color: Colors.white),)),
                        DropdownMenuEntry(value: Colors.white, label: 'White',
                          labelWidget: Text(
                            'White',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuEntry(value: Colors.grey, label: 'Gray',
                          labelWidget: Text(
                            'Gray',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        
                        DropdownMenuEntry(value: Colors.red, label: 'Red',
                        labelWidget: Text(
                            'Red',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    // Container(
                    //   width: 200,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: colors.map((color) {
                    //       return GestureDetector(
                    //         onTap: () {
                    //           setState(() {
                    //             selectedColor = color;
                    //           });
                    //         },
                    //         child: AnimatedContainer(
                    //           padding: EdgeInsets.all(16),
                    //           duration: Duration(milliseconds: 200),
                    //           decoration: BoxDecoration(
                    //             color: color,
                    //             borderRadius: BorderRadius.circular(25),
                    //             border: (selectedColor == color)
                    //                 ? Border.all(color: Colors.white, width: 2)
                    //                 : null,
                    //           ),
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
                    const SizedBox(height: 15),
                    Text('Qunatity', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (qunatityNumber <= 1) return;
                                qunatityNumber--;
                              });
                            },
                            icon: Icon(Icons.remove),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${qunatityNumber}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                qunatityNumber++;
                              });
                            },
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Builder(
                      builder: (context) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added To Cart Successfully',
                                  style: TextStyle(color: Colors.black),
                                ),
                                action: SnackBarAction(
                                  label: 'Click here ',
                                  textColor: Colors.green,
                                  onPressed: () {
                                    //cart screen
                                  },
                                ),
                                backgroundColor: Colors.white,
                              ),
                            );
                          },
                          label: Text(
                            'Add To Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: Icon(Icons.shopping_cart, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        //cart screen
                      },
                      child: Text(
                        'Buy Now',
                        style: TextStyle(color: Colors.white),
                      ),
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
