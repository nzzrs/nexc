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

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _sourceUrl = 'https://github.com/nzzrs/nexc';
  static const String _reportUrl = 'https://github.com/nzzrs/nexc/issues/new';

  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      NexcSnack.show(context, context.l10n.couldNotOpenUrl(url));
    }
  }

  void _showPrivacy() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.privacyPolicy),
        content: SingleChildScrollView(child: Text(l10n.privacyPolicyBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _showLicense() {
    final l10n = context.l10n;
    // The upstream attribution clause requires this exact credit:
    // Based on LibreFit © IamDg and the LibreFit Contributors
    showLicensePage(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: _packageInfo?.version ?? '',
      applicationLegalese: l10n.licenseLegalese,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final String version = _packageInfo != null
        ? l10n.versionWithBuild(
            _packageInfo!.version,
            _packageInfo!.buildNumber,
          )
        : l10n.loadingVersion;

    return NexcPage(
      title: l10n.aboutTitle,
      body: ListView(
        padding: const EdgeInsets.only(
          top: NexcSpacing.xl,
          bottom: NexcSpacing.xl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.lg),
            child: Material(
              color: theme.colorScheme.surfaceContainerLow,
              shape: const RoundedRectangleBorder(
                borderRadius: NexcShapes.lgRadius,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(NexcSpacing.xl),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: NexcShapes.xlRadius,
                          ),
                          child: Icon(
                            NexcIcons.workout,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: NexcSpacing.lg),
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: NexcSpacing.xs),
                        Text(
                          version,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  NexcTile(
                    icon: NexcIcons.privacy,
                    title: l10n.privacyPolicy,
                    subtitle: l10n.privacyPolicyDescription,
                    showChevron: true,
                    onTap: _showPrivacy,
                  ),
                  const Divider(height: 1),
                  NexcTile(
                    icon: NexcIcons.license,
                    title: l10n.license,
                    subtitle: l10n.licenseDescription,
                    showChevron: true,
                    onTap: _showLicense,
                  ),
                  const Divider(height: 1),
                  NexcTile(
                    icon: NexcIcons.attribution,
                    title: l10n.github,
                    subtitle: l10n.githubDescription,
                    showChevron: true,
                    onTap: () => _launchUrl(_sourceUrl),
                  ),
                  const Divider(height: 1),
                  NexcTile(
                    icon: NexcIcons.warning,
                    title: l10n.reportBug,
                    subtitle: l10n.reportBugDescription,
                    showChevron: true,
                    onTap: () => _launchUrl(_reportUrl),
                  ),
                  const Divider(height: 1),
                  NexcTile(
                    icon: NexcIcons.about,
                    title: l10n.libreFitName,
                    subtitle: l10n.libreFitDescription,
                    showChevron: true,
                    onTap: () =>
                        _launchUrl('https://github.com/LibreFitOrg/LibreFit'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NexcSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.xl),
            child: Text(
              l10n.madeWithLove,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
