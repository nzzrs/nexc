/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/shapes.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/unit_system.dart';
import '../../l10n/app_localizations.dart';

/// Height is stored in centimetres; the form edits the user's unit.
const double _centimetresPerInch = 2.54;

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _heightController = TextEditingController();
  final _preferencesController = TextEditingController();

  DateTime? _selectedBirthDate;
  DateTime? _savedBirthDate;
  String _savedHeightText = '';
  String _savedPreferences = '';
  String? _heightError;
  bool _isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_onFieldChanged);
    _preferencesController.addListener(_onFieldChanged);
    _loadUserData();
  }

  @override
  void dispose() {
    _heightController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _preferencesController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  String _heightLabel(AppLocalizations l10n, UnitSystem system) {
    if (system == UnitSystem.metric) return l10n.heightCm;
    final String base = l10n.heightCm
        .replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '')
        .trim();
    return '$base (in)';
  }

  String _displayHeight(double? centimetres, UnitSystem system) {
    if (centimetres == null) return '';
    final double value = system == UnitSystem.metric
        ? centimetres
        : centimetres / _centimetresPerInch;
    return formatDecimal(value, maxDecimals: 1);
  }

  Future<void> _loadUserData() async {
    final user = await ref.read(userRepositoryProvider).getUser();
    if (!mounted) return;
    final UnitSystem system = ref.read(settingsProvider).unitSystem;
    final String heightText = _displayHeight(user?.height, system);
    final String preferences = ref.read(settingsProvider).userPreferences;
    _heightController.text = heightText;
    _preferencesController.text = preferences;
    setState(() {
      _selectedBirthDate = user?.birthDate;
      _savedBirthDate = user?.birthDate;
      _savedHeightText = heightText;
      _savedPreferences = preferences;
      _isLoading = false;
    });
  }

  bool get _hasChanges =>
      _heightController.text.trim() != _savedHeightText ||
      _selectedBirthDate != _savedBirthDate ||
      _preferencesController.text != _savedPreferences;

  Future<void> _save() async {
    if (_saving) return;
    final SettingsState settings = ref.read(settingsProvider);
    final AppLocalizations l10n = context.l10n;
    final String heightText = _heightController.text.trim();

    double? heightCentimetres;
    if (heightText.isNotEmpty) {
      final double? entered = double.tryParse(heightText.replaceAll(',', '.'));
      if (entered == null || entered <= 0) {
        setState(
          () => _heightError = l10n.errorWithMessage(
            _heightLabel(l10n, settings.unitSystem),
          ),
        );
        return;
      }
      heightCentimetres = settings.unitSystem == UnitSystem.metric
          ? entered
          : entered * _centimetresPerInch;
    }

    setState(() {
      _saving = true;
      _heightError = null;
    });

    await ref
        .read(userRepositoryProvider)
        .saveUser(birthDate: _selectedBirthDate, height: heightCentimetres);
    await ref
        .read(settingsProvider.notifier)
        .setUserPreferences(_preferencesController.text);

    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedHeightText = heightText;
      _savedBirthDate = _selectedBirthDate;
      _savedPreferences = _preferencesController.text;
    });
    NexcSnack.show(context, l10n.personalInfoSaved);
  }

  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate() async {
    final DateTime initialDate = _selectedBirthDate ?? DateTime(2000, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final UnitSystem system = ref.watch(settingsProvider).unitSystem;
    final int? age = _calculateAge(_selectedBirthDate);

    return NexcPage(
      title: l10n.personalInformation,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(
                top: NexcSpacing.md,
                bottom: NexcSpacing.xxl,
              ),
              children: [
                NexcSection(
                  title: l10n.yourProfileMetrics,
                  padded: true,
                  children: [
                    TextField(
                      key: const ValueKey<String>('height'),
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _heightLabel(l10n, system),
                        prefixIcon: const Icon(NexcIcons.units, size: 20),
                        errorText: _heightError,
                      ),
                      onChanged: (_) {
                        if (_heightError != null) {
                          setState(() => _heightError = null);
                        }
                      },
                    ),
                    const SizedBox(height: NexcSpacing.md),
                    NexcTile(
                      icon: NexcIcons.calendar,
                      title: _selectedBirthDate == null
                          ? l10n.selectBirthday
                          : l10n.birthdayWithDate(
                              context.formatMediumDate(_selectedBirthDate!),
                            ),
                      onTap: _selectDate,
                      showChevron: true,
                    ),
                    if (age != null) ...[
                      const SizedBox(height: NexcSpacing.md),
                      Material(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: NexcShapes.mdRadius,
                        child: Padding(
                          padding: const EdgeInsets.all(NexcSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                NexcIcons.calendar,
                                size: 20,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: NexcSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.calculatedAge(age),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                NexcSection(
                  title: l10n.userPreferencesTitle,
                  description: l10n.aiPreferencesContext,
                  padded: true,
                  children: [
                    TextField(
                      controller: _preferencesController,
                      minLines: 4,
                      maxLines: 12,
                      decoration: InputDecoration(
                        hintText: l10n.preferencesHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomBar: Row(
        children: [
          if (_hasChanges) ...[
            Semantics(
              label: l10n.saveChanges,
              child: Container(
                width: NexcSpacing.sm,
                height: NexcSpacing.sm,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: NexcSpacing.sm),
          ],
          Expanded(
            child: FilledButton.icon(
              onPressed: _hasChanges && !_saving ? _save : null,
              icon: const Icon(NexcIcons.check),
              label: Text(l10n.saveChanges),
            ),
          ),
        ],
      ),
    );
  }
}
