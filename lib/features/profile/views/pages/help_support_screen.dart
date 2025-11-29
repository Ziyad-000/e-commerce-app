import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

// في أول الملف
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  // FAQs Data
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I track my order?',
      'category': 'Orders',
      'answer':
          'You can track your order by going to "My Orders" in your profile and clicking on the specific order. You\'ll see real-time tracking information and estimated delivery date.',
    },
    {
      'question': 'What is your return policy?',
      'category': 'Returns',
      'answer':
          'We offer a 30-day return policy for all items in original condition. Items must be unworn, unwashed, and have all original tags attached. Free returns are available for defective items.',
    },
    {
      'question': 'How long does shipping take?',
      'category': 'Shipping',
      'answer':
          'Standard shipping takes 5-7 business days, while express shipping takes 2-3 business days. Free shipping is available on orders over \$50.',
    },
    {
      'question': 'How do I change or cancel my order?',
      'category': 'Orders',
      'answer':
          'Orders can be modified or cancelled within 1 hour of placement. After that, please contact customer support for assistance.',
    },
    {
      'question': 'What payment methods do you accept?',
      'category': 'Payment',
      'answer':
          'We accept all major credit cards (Visa, Mastercard, American Express), PayPal, Apple Pay, and Google Pay. All payments are processed securely.',
    },
  ];

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
          'Help & Support',
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                style: const TextStyle(color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: const TextStyle(color: AppColors.mutedForeground),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.mutedForeground,
                  ),
                  filled: true,
                  fillColor: AppColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Get Quick Help
            _buildSectionHeader('Get Quick Help'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Live Chat Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                      label: const Text(
                        'Live Chat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Call Us Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _launchUrl('tel:1-800-327-4466');
                      },
                      icon: const Icon(Icons.phone_outlined, size: 20),
                      label: const Text(
                        'Call Us',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _launchUrl('mailto:support@clothingstore.com');
                      },
                      icon: const Icon(Icons.email_outlined, size: 20),
                      label: const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Browse by Category
            _buildSectionHeader('Browse by Category'),
            _buildCategoryItem(
              icon: Icons.local_shipping_outlined,
              title: 'Orders & Tracking',
              subtitle: 'Get help with orders & tracking',
              iconColor: const Color(0xFF6366F1),
              onTap: () {},
            ),
            _buildCategoryItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment & Billing',
              subtitle: 'Learn about payment & billing',
              iconColor: const Color(0xFF10B981),
              onTap: () {},
            ),
            _buildCategoryItem(
              icon: Icons.keyboard_return,
              title: 'Returns & Refunds',
              subtitle: 'Get help with returns & refunds',
              iconColor: const Color(0xFFF59E0B),
              onTap: () {},
            ),
            _buildCategoryItem(
              icon: Icons.account_circle_outlined,
              title: 'Account & Privacy',
              subtitle: 'Get help with accounts & privacy',
              iconColor: const Color(0xFFEC4899),
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Frequently Asked Questions (NEW DESIGN)
            _buildSectionHeader('Frequently Asked Questions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  _faqs.length,
                  (index) => _buildFaqExpansionTile(
                    question: _faqs[index]['question']!,
                    category: _faqs[index]['category']!,
                    answer: _faqs[index]['answer']!,
                    index: index,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Still Need Help Footer
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our customer support team is available 24/7 to assist you.',
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    Icons.email_outlined,
                    'support@clothingstore.com',
                    () => _launchUrl('mailto:support@clothingstore.com'),
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    Icons.phone_outlined,
                    '1-800-FASHION (1-800-327-4466)',
                    () => _launchUrl('tel:1-800-327-4466'),
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    Icons.chat_bubble_outline,
                    'Live chat available',
                    () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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

  Widget _buildFaqExpansionTile({
    required String question,
    required String category,
    required String answer,
    required int index,
  }) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.foreground,
            size: 20,
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              category,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
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

  Widget _buildContactItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.foreground, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
