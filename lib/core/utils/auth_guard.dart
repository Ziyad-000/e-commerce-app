import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../routes/app_routes.dart';

class AuthGuard {
  static bool checkAuth(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginRoute,
        (route) => false,
      );
      return false;
    }
    return true;
  }
}
