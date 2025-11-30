import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class AuthGuard {
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static bool checkAuth(BuildContext context, {String? redirectTo}) {
    if (!isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginRoute,
          (route) => false,
          arguments: redirectTo,
        );
      });
      return false;
    }
    return true;
  }

  static Future<bool> requireAuth(
    BuildContext context, {
    String? redirectTo,
    VoidCallback? onAuthenticated,
  }) async {
    if (!isAuthenticated()) {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.loginRoute,
        arguments: redirectTo,
      );

      if (result == true && isAuthenticated()) {
        onAuthenticated?.call();
        return true;
      }
      return false;
    }

    onAuthenticated?.call();
    return true;
  }

  static String? getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static String? getUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  static bool isAnonymous() {
    return FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
  }
}
