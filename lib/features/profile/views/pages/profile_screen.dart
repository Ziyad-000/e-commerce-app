import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.destructive),
            ),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Please sign in',
                      style: TextStyle(
                        color: AppColors.foreground,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to view your profile and orders',
                      style: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.loginRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Logged in
        final user = snapshot.data!;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.destructive,
                        child: Text(
                          _getInitial(user.displayName),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? 'Guest User',
                              style: const TextStyle(
                                color: AppColors.foreground,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? 'guest@example.com',
                              style: const TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Order History',
                  subtitle: 'Track and view your orders',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.orderHistoryRoute);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.favorite_border,
                  title: 'Saved Items',
                  subtitle: 'Your favorite products',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.savedItemsRoute);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'Addresses',
                  subtitle: 'Manage shipping addresses',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.addressesRoute);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage cards and payment',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.paymentMethodsRoute);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with your account',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.helpSupportRoute);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'App preferences and privacy',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.settingsRoute);
                  },
                ),

                const Divider(height: 1, color: AppColors.border),

                // Sign Out
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: '',
                  textColor: AppColors.destructive,
                  iconColor: AppColors.destructive,
                  showArrow: false,
                  onTap: () async {
                    final confirm = await _showLogoutDialog(context);
                    if (confirm == true) {
                      await FirebaseAuth.instance.signOut();
                    }
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return 'G';
    return name[0].toUpperCase();
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.foreground, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? AppColors.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.mutedForeground,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.foreground),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.foreground),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
