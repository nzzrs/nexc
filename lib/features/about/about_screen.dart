/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // App Logo Placeholder / Icon
          Center(
            child: Container(
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
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader(context, 'Info'),
          const SizedBox(height: 8),
          _AboutItem(
            text: 'Tutorial',
            description: 'Learn how to use Nexc',
            icon: Icons.help_outline,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tutorial not implemented yet')),
              );
            },
          ),
          _AboutItem(
            text: 'Privacy',
            description: 'Read our privacy policy',
            icon: Icons.privacy_tip_outlined,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy not implemented yet')),
              );
            },
          ),
          _AboutItem(
            text: 'License',
            description: 'GPL-3.0 License details',
            icon: Icons.gavel_outlined,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('License details not implemented yet')),
              );
            },
          ),
          _AboutItem(
            text: 'GitHub',
            description: 'View source code on GitHub',
            icon: Icons.code,
            onClick: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Source Code'),
                  content: const SelectableText('https://github.com/nzzrs/nexc'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          _AboutItem(
            text: 'Dependencies',
            description: 'Third-party libraries used in Nexc',
            icon: Icons.info_outline,
            onClick: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dependencies list not implemented yet')),
              );
            },
          ),
          _AboutItem(
            text: 'Original Project',
            description: 'Based on LibreFit by IamDg and contributors',
            icon: Icons.favorite_outline,
            onClick: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('LibreFit'),
                  content: const SelectableText('https://github.com/LibreFitOrg/LibreFit'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
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
                Icon(
                  icon,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
