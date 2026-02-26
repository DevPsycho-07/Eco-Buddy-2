import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: February 17, 2026',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              '1. Introduction',
              'Eco Daily Score ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            
            _buildSection(
              context,
              '2. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n• Account Information: Name, email address, profile picture\n• Activity Data: Your logged activities, transportation choices, dietary habits\n• Location Data: GPS coordinates for travel tracking (with your permission)\n• Device Information: Device type, operating system, unique device identifiers\n• Usage Data: How you interact with the App, features used, time spent',
            ),
            
            _buildSection(
              context,
              '3. How We Use Your Information',
              'We use the collected information to:\n\n• Provide and maintain the App\'s functionality\n• Calculate your eco score and CO₂ emissions\n• Personalize your experience and recommendations\n• Send notifications and updates (if enabled)\n• Improve and optimize the App\n• Analyze usage patterns and trends\n• Communicate with you about the service\n• Ensure the security of the App',
            ),
            
            _buildSection(
              context,
              '4. Data Storage and Security',
              'We implement appropriate technical and organizational measures to protect your personal data. Your data is encrypted both in transit and at rest. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
            ),
            
            _buildSection(
              context,
              '5. Data Sharing and Disclosure',
              'We do not sell your personal information. We may share your information:\n\n• With your explicit consent\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• With service providers who assist in App operations (under strict confidentiality agreements)\n• In anonymized, aggregated form for research purposes',
            ),
            
            _buildSection(
              context,
              '6. Your Rights and Choices',
              'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Request deletion of your data\n• Export your data\n• Opt-out of notifications\n• Revoke location permissions\n• Delete your account\n\nYou can exercise these rights through the App settings or by contacting us.',
            ),
            
            _buildSection(
              context,
              '7. Location Data',
              'The App may collect location data to track your travel activities and calculate transportation-related emissions. You can control location permissions through your device settings. Disabling location services may limit some App features.',
            ),
            
            _buildSection(
              context,
              '8. Children\'s Privacy',
              'The App is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we discover that we have collected such information, we will delete it immediately.',
            ),
            
            _buildSection(
              context,
              '9. Data Retention',
              'We retain your personal data for as long as your account is active or as needed to provide services. When you delete your account, we will delete or anonymize your personal data within 30 days, except where we are required to retain it for legal purposes.',
            ),
            
            _buildSection(
              context,
              '10. Third-Party Services',
              'The App may contain links to third-party services. We are not responsible for the privacy practices of these services. We encourage you to read their privacy policies.',
            ),
            
            _buildSection(
              context,
              '11. Analytics',
              'We use analytics tools to understand how users interact with the App. These tools may collect information such as usage patterns, crashes, and performance data. This data is used solely for improving the App.',
            ),
            
            _buildSection(
              context,
              '12. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the App and updating the "Last Updated" date. Your continued use after changes constitutes acceptance.',
            ),
            
            _buildSection(
              context,
              '13. International Data Transfers',
              'Your information may be transferred to and maintained on servers located outside of your country. We will take appropriate measures to ensure your data receives adequate protection.',
            ),
            
            _buildSection(
              context,
              '14. Contact Us',
              'If you have questions or concerns about this Privacy Policy or our data practices, please contact us at:\n\nEmail: support@ecodailyscore.com\nSubject: Privacy Inquiry',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
