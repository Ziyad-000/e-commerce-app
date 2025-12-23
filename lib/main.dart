import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/address/providers/address_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/cart/providers/checkout_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/payment/providers/payment_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/products/providers/category_provider.dart';
import 'features/search/providers/search_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final cartProvider = CartProvider();
            cartProvider.loadCachedCart(); // Load cart from local storage
            return cartProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Fashion Store',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splashRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
