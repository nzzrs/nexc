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

import '../../core/l10n/l10n.dart';

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
          SnackBar(content: Text(context.l10n.couldNotOpenUrl(url))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final version = _packageInfo != null
        ? l10n.versionWithBuild(
            _packageInfo!.version,
            _packageInfo!.buildNumber,
          )
        : l10n.loadingVersion;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
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
                'assets/images/logo.png',
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
              l10n.appName,
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

          _buildSectionHeader(context, l10n.info),
          const SizedBox(height: 8),
          _AboutItem(
            text: l10n.privacyPolicy,
            description: l10n.privacyPolicyDescription,
            icon: Icons.privacy_tip_outlined,
            onClick: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.privacyPolicy),
                  content: SingleChildScrollView(
                    child: Text(l10n.privacyPolicyBody),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.gotIt),
                    ),
                  ],
                ),
              );
            },
          ),
          _AboutItem(
            text: l10n.license,
            description: l10n.licenseDescription,
            icon: Icons.gavel_outlined,
            onClick: () {
              showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: _packageInfo?.version ?? '',
                // The upstream attribution clause requires this exact credit.
                // English text: "Based on LibreFit © IamDg and the LibreFit Contributors".
                applicationLegalese: l10n.licenseLegalese,
              );
            },
          ),
          _AboutItem(
            text: l10n.github,
            description: l10n.githubDescription,
            icon: Icons.code,
            onClick: () => _launchUrl('https://github.com/nzzrs/nexc'),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, l10n.attribution),
          const SizedBox(height: 8),
          _AboutItem(
            text: l10n.libreFitName,
            description: l10n.libreFitDescription,
            icon: Icons.favorite_outline,
            onClick: () =>
                _launchUrl('https://github.com/LibreFitOrg/LibreFit'),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, l10n.contact),
          const SizedBox(height: 8),
          _AboutItem(
            text: l10n.reportBug,
            description: l10n.reportBugDescription,
            icon: Icons.bug_report_outlined,
            onClick: () =>
                _launchUrl('https://github.com/nzzrs/nexc/issues/new'),
          ),
          _AboutItem(
            text: l10n.suggestFeature,
            description: l10n.suggestFeatureDescription,
            icon: Icons.lightbulb_outline,
            onClick: () =>
                _launchUrl('https://github.com/nzzrs/nexc/discussions'),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.madeWithLove,
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
