import 'package:flutter/material.dart';
import '../../features/auth/views/pages/splach_screen.dart';
import '../../features/auth/views/pages/login_screen.dart';
import '../../features/auth/views/pages/register_screen.dart';
import '../../features/auth/views/pages/reset_password_screen.dart';
import '../../features/cart/views/pages/cart_screen.dart';
import '../../features/products/models/product_model.dart';
import '../../features/products/views/pages/product_details_screen.dart';
import '../../features/products/views/pages/product_screen.dart';
import '../../features/profile/views/pages/profile_screen.dart';
import '../../features/profile/views/pages/settings_screen.dart';
import '../../features/profile/views/pages/help_support_screen.dart';
import '../../features/profile/views/pages/order_history_screen.dart';
import '../../features/profile/views/pages/saved_items_screen.dart';
import '../../features/profile/views/pages/addresses_screen.dart';
import '../../features/profile/views/pages/payment_methods_screen.dart';
import '../../main_layout.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.resetPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case AppRoutes.mainLayoutRoute:
        return MaterialPageRoute(builder: (_) => const MainLayout());

      case AppRoutes.productsRoute:
        return MaterialPageRoute(
          builder: (context) {
            final categoryName = settings.arguments.toString();
            return ProductScreen(categoryName: categoryName);
          },
        );

      case AppRoutes.productDetailsRoute:
        return MaterialPageRoute(
          builder: (context) {
            final ProductModel product = settings.arguments as ProductModel;
            return ProductDetailsScreen(product: product);
          },
        );

      case AppRoutes.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.cartRoute:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case AppRoutes.orderHistoryRoute:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());

      case AppRoutes.savedItemsRoute:
        return MaterialPageRoute(builder: (_) => const SavedItemsScreen());

      case AppRoutes.addressesRoute:
        return MaterialPageRoute(builder: (_) => const AddressesScreen());

      case AppRoutes.paymentMethodsRoute:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());

      case AppRoutes.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.helpSupportRoute:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No route defined for this path')),
          ),
        );
    }
  }
}
