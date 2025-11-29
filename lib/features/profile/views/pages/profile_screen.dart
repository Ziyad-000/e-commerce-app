import 'package:ecommerce_app/features/profile/views/pages/payment_methods_screen.dart';
import 'package:ecommerce_app/features/profile/views/pages/saved_items_screen.dart';
import 'package:ecommerce_app/features/profile/views/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'addresses_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual auth state
    final bool isLoggedIn = false;
    final String userName = 'Guest User';
    final String userInitials = 'GU';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Info Section
              if (!isLoggedIn) ...[
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.destructive,
                  child: Text(
                    userInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Welcome Message
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sign in to access your account',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Auth Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to sign in
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to sign up
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.foreground,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: 'Order History',
                subtitle: 'Track and view your orders',
                onTap: () {
                  // TODO: Navigate to order history
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.favorite_border,
                title: 'Saved Items',
                subtitle: 'Your favorite products',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedItemsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                subtitle: 'Manage shipping addresses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressesScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage cards and payment',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help with your account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences and privacy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Footer
              Column(
                children: [
                  const Text(
                    'StyleShop v1.0.0',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mutedForeground,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                      const Text(
                        '•',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mutedForeground,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.foreground, size: 20),
            ),
            const SizedBox(width: 16),

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
