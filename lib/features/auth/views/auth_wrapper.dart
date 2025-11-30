import 'package:ecommerce_app/features/auth/views/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main_layout.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const MainLayout();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
