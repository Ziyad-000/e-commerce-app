import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainLayoutRoute,
        (route) => false,
      );
    } else {
      // User not logged in
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 60,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'StyleShop',
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Fashion Destination',
              style: TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),

            // Loading Indicator
            const CircularProgressIndicator(
              color: AppColors.destructive,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
