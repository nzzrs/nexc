/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _packageInfo = info);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final version = _packageInfo != null
        ? 'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})'
        : 'Loading version…';

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          // App Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/nexc_logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stack) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Nexc',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              version,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(context, 'Info'),
          const SizedBox(height: 8),
          _AboutItem(
            text: 'Privacy Policy',
            description: 'No data leaves your device. Ever.',
            icon: Icons.privacy_tip_outlined,
            onClick: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Nexc does not collect, store, or transmit any personal data. '
                      'All workout and nutrition data is stored exclusively on your device '
                      'in a local database. No analytics, no crash reporting services, '
                      'no third-party SDKs that phone home.\n\n'
                      'Your data is your data.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
          _AboutItem(
            text: 'License',
            description: 'GNU General Public License v3.0',
            icon: Icons.gavel_outlined,
            onClick: () {
              showLicensePage(
                context: context,
                applicationName: 'Nexc',
                applicationVersion: _packageInfo?.version ?? '',
                applicationLegalese:
                    '© 2026 Nexc Contributors\n'
                    'Based on LibreFit © IamDg and the LibreFit Contributors\n'
                    'Licensed under the GNU General Public License v3.0',
              );
            },
          ),
          _AboutItem(
            text: 'GitHub',
            description: 'View source code on GitHub',
            icon: Icons.code,
            onClick: () => _launchUrl('https://github.com/nzzrs/nexc'),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Attribution'),
          const SizedBox(height: 8),
          _AboutItem(
            text: 'LibreFit',
            description: 'The open-source project Nexc is based on — by IamDg and contributors',
            icon: Icons.favorite_outline,
            onClick: () => _launchUrl('https://github.com/LibreFitOrg/LibreFit'),
          ),
          _AboutItem(
            text: 'wger exercise database',
            description: 'Exercise data licensed under Creative Commons BY-SA 4.0',
            icon: Icons.sports_gymnastics,
            onClick: () => _launchUrl('https://wger.de'),
          ),
          _AboutItem(
            text: 'Open Food Facts',
            description: 'Nutritional data licensed under ODbL',
            icon: Icons.set_meal_outlined,
            onClick: () => _launchUrl('https://openfoodfacts.org'),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Contact'),
          const SizedBox(height: 8),
          _AboutItem(
            text: 'Report a bug',
            description: 'Open an issue on GitHub',
            icon: Icons.bug_report_outlined,
            onClick: () => _launchUrl('https://github.com/nzzrs/nexc/issues/new'),
          ),
          _AboutItem(
            text: 'Suggest a feature',
            description: 'Open a discussion on GitHub',
            icon: Icons.lightbulb_outline,
            onClick: () => _launchUrl('https://github.com/nzzrs/nexc/discussions'),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Made with ❤️ — built on the shoulders of giants.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  final String text;
  final String description;
  final IconData icon;
  final VoidCallback onClick;

  const _AboutItem({
    required this.text,
    required this.description,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
