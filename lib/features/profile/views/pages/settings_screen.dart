import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool darkMode = true;
  bool biometricAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildToggleItem(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive notifications about orders and offers',
              value: pushNotifications,
              onChanged: (value) {
                setState(() {
                  pushNotifications = value;
                });
              },
            ),
            _buildToggleItem(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Get updates via email',
              value: emailNotifications,
              onChanged: (value) {
                setState(() {
                  emailNotifications = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // App Preferences Section
            _buildSectionHeader('App Preferences'),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Use dark theme throughout the app',
              value: darkMode,
              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),
            _buildNavigationItem(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () {
                // TODO: Navigate to language selection
              },
            ),

            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('Security'),
            _buildToggleItem(
              icon: Icons.fingerprint,
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face unlock',
              value: biometricAuth,
              onChanged: (value) {
                setState(() {
                  biometricAuth = value;
                });
              },
            ),
            _buildNavigationItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Settings',
              subtitle: 'Manage your privacy preferences',
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.foreground,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.destructive, size: 20),
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
                    fontWeight: FontWeight.w500,
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

          // Toggle Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.destructive,
            activeTrackColor: AppColors.destructive.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.destructive, size: 20),
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
                      fontWeight: FontWeight.w500,
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
