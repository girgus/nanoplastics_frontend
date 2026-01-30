import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../widgets/nanosolve_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelLavender.withValues(alpha: 0.05),
              AppColors.pastelAqua.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.pastelLavender,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Icon(Icons.info_outline,
                    size: 24, color: AppColors.pastelLavender),
              ],
            ),
            const SizedBox(height: 15),
            const NanosolveLogo(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          _buildAppInfo(),
          const SizedBox(height: 30),
          _buildSectionTitle('About NanoSolve'),
          const SizedBox(height: 15),
          _buildDescriptionCard(),
          const SizedBox(height: 30),
          _buildSectionTitle('Connect'),
          const SizedBox(height: 15),
          _buildLinkItem(
            title: 'Website',
            subtitle: 'nanosolve.io',
            icon: Icons.language,
            color: AppColors.pastelAqua,
            onTap: () => _launchUrl('https://nanosolve.io'),
          ),
          const SizedBox(height: 15),
          _buildLinkItem(
            title: 'Contact Us',
            subtitle: 'Get in touch with our team',
            icon: Icons.email_outlined,
            color: AppColors.pastelMint,
            onTap: () => _launchUrl('mailto:contact@nanosolve.io'),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Legal'),
          const SizedBox(height: 15),
          _buildLinkItem(
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            icon: Icons.policy_outlined,
            color: AppColors.pastelLavender,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const SizedBox(height: 15),
          _buildLinkItem(
            title: 'Terms of Service',
            subtitle: 'Terms and conditions',
            icon: Icons.description_outlined,
            color: AppColors.pastelLavender,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),
          const SizedBox(height: 30),
          _buildLinkItem(
            title: 'Open Source Licenses',
            subtitle: 'Third-party libraries we use',
            icon: Icons.code,
            color: AppColors.pastelAqua,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'NanoSolve Hive',
              applicationVersion: 'v$appVersion ($buildNumber)',
            ),
          ),
          const SizedBox(height: 40),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF141928),
            border: Border.all(
              color: AppColors.pastelLavender.withValues(alpha: 0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pastelLavender.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: NanosolveLogo(height: 50),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelAqua, AppColors.pastelMint],
          ).createShader(bounds),
          child: const Text(
            'NanoSolve Hive',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version $appVersion ($buildNumber)',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.pastelLavender,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.pastelLavender,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppColors.pastelLavender.withValues(alpha: 0.2)),
      ),
      child: Text(
        'NanoSolve Hive is your gateway to understanding nanoplastics and their impact on human health and the environment. We provide science-backed information to help you make informed decisions.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildLinkItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF141928).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Made with care for a cleaner planet',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '2024 NanoSolve. All rights reserved.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    debugPrint('🔗 [URLLauncher] Launching URL: $url');
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 [URLLauncher] Parsed URI: $uri');
      debugPrint(
          '🔗 [URLLauncher] Attempting to launch in external application...');

      if (await canLaunchUrl(uri)) {
        debugPrint('🔗 [URLLauncher] URL is launchable');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('🔗 [URLLauncher] URL launched successfully');
      } else {
        debugPrint('❌ [URLLauncher] Cannot launch URL: $url');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [URLLauncher] Error launching $url: $e');
      debugPrint('❌ [URLLauncher] Stack trace: $stackTrace');
    }
  }
}
