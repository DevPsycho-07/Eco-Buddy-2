import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using Eco Daily Score ("the App"), you accept and agree to be bound by the terms and conditions of this agreement. If you do not agree to these terms, please do not use the App.',
            ),
            
            _buildSection(
              context,
              '2. Description of Service',
              'Eco Daily Score is a mobile application designed to help users track and reduce their carbon footprint. The App provides features including activity tracking, CO₂ emission calculations, eco-score monitoring, and sustainability recommendations.',
            ),
            
            _buildSection(
              context,
              '3. User Accounts',
              'You are responsible for maintaining the confidentiality of your account credentials. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
            ),
            
            _buildSection(
              context,
              '4. User Content and Data',
              'You retain all rights to the data you input into the App. By using the App, you grant us a license to use, store, and process your data to provide and improve our services. We will handle your data in accordance with our Privacy Policy.',
            ),
            
            _buildSection(
              context,
              '5. CO₂ Calculations',
              'While we strive for accuracy, CO₂ emission calculations are estimates based on standard environmental data and algorithms. Actual emissions may vary. These calculations should be used for informational purposes only.',
            ),
            
            _buildSection(
              context,
              '6. Acceptable Use',
              'You agree not to:\n• Use the App for any illegal or unauthorized purpose\n• Attempt to gain unauthorized access to the App or related systems\n• Interfere with or disrupt the App\'s functionality\n• Upload malicious code or content\n• Misrepresent your identity or affiliation',
            ),
            
            _buildSection(
              context,
              '7. Intellectual Property',
              'The App and its original content, features, and functionality are owned by Eco Daily Score and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            
            _buildSection(
              context,
              '8. Disclaimer of Warranties',
              'The App is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, secure, or error-free.',
            ),
            
            _buildSection(
              context,
              '9. Limitation of Liability',
              'In no event shall Eco Daily Score be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the App.',
            ),
            
            _buildSection(
              context,
              '10. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes. Continued use of the App after changes constitutes acceptance of the modified terms.',
            ),
            
            _buildSection(
              context,
              '11. Account Termination',
              'We reserve the right to terminate or suspend your account at our discretion for violations of these terms. You may also delete your account at any time through the App settings.',
            ),
            
            _buildSection(
              context,
              '12. Contact Information',
              'For questions about these Terms of Service, please contact us at:\nsupport@ecodailyscore.com',
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
