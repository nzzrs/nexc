/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

import '../theme/iconography.dart';
import '../theme/shapes.dart';
import '../theme/spacing.dart';

/// One option inside a [NexcChoiceSheet].
class NexcChoiceOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final bool enabled;

  const NexcChoiceOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.enabled = true,
  });
}

/// Modal single-choice sheet used by every picker in the app.
///
/// Search appears automatically when the list is long (languages, equipment).
class NexcChoiceSheet<T> extends StatefulWidget {
  final String title;
  final List<NexcChoiceOption<T>> options;
  final T? selected;
  final String? searchHint;
  final bool searchable;

  const NexcChoiceSheet({
    super.key,
    required this.title,
    required this.options,
    this.selected,
    this.searchHint,
    this.searchable = false,
  });

  /// Shows the sheet and returns the chosen value, or null when dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<NexcChoiceOption<T>> options,
    T? selected,
    String? searchHint,
    bool searchable = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) => NexcChoiceSheet<T>(
        title: title,
        options: options,
        selected: selected,
        searchHint: searchHint,
        searchable: searchable,
      ),
    );
  }

  @override
  State<NexcChoiceSheet<T>> createState() => _NexcChoiceSheetState<T>();
}

class _NexcChoiceSheetState<T> extends State<NexcChoiceSheet<T>> {
  String _query = '';

  List<NexcChoiceOption<T>> get _filtered {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where(
          (NexcChoiceOption<T> option) =>
              option.label.toLowerCase().contains(query) ||
              (option.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool showSearch = widget.searchable && widget.options.length > 6;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.xl,
              NexcSpacing.sm,
              NexcSpacing.xl,
              NexcSpacing.md,
            ),
            child: Text(widget.title, style: theme.textTheme.headlineSmall),
          ),
          if (showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                0,
                NexcSpacing.lg,
                NexcSpacing.md,
              ),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(NexcIcons.search),
                ),
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: NexcSpacing.lg),
              itemCount: _filtered.length,
              itemBuilder: (BuildContext context, int index) {
                final NexcChoiceOption<T> option = _filtered[index];
                final bool isSelected = option.value == widget.selected;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NexcSpacing.md,
                    vertical: 2,
                  ),
                  child: ListTile(
                    enabled: option.enabled,
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.secondaryContainer,
                    selectedColor: theme.colorScheme.onSecondaryContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: NexcShapes.mdRadius,
                    ),
                    leading: option.icon == null ? null : Icon(option.icon),
                    title: Text(option.label),
                    subtitle: option.description == null
                        ? null
                        : Text(option.description!),
                    trailing: isSelected
                        ? const Icon(NexcIcons.check, size: 20)
                        : null,
                    onTap: option.enabled
                        ? () => Navigator.pop(context, option.value)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Text input modal sheet for short values (names, thresholds).
class NexcInputSheet extends StatefulWidget {
  final String title;
  final String? label;
  final String? hint;
  final String? helper;
  final String initialValue;
  final String confirmLabel;
  final TextInputType keyboardType;
  final String? Function(String value)? validator;

  const NexcInputSheet({
    super.key,
    required this.title,
    this.label,
    this.hint,
    this.helper,
    this.initialValue = '',
    this.confirmLabel = 'OK',
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? label,
    String? hint,
    String? helper,
    String initialValue = '',
    String confirmLabel = 'OK',
    TextInputType keyboardType = TextInputType.text,
    String? Function(String value)? validator,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) => NexcInputSheet(
        title: title,
        label: label,
        hint: hint,
        helper: helper,
        initialValue: initialValue,
        confirmLabel: confirmLabel,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  State<NexcInputSheet> createState() => _NexcInputSheetState();
}

class _NexcInputSheetState extends State<NexcInputSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    final String? error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NexcSpacing.xl,
        NexcSpacing.sm,
        NexcSpacing.xl,
        NexcSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: NexcSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              helperText: widget.helper,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: NexcSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              const SizedBox(width: NexcSpacing.sm),
              FilledButton(
                onPressed: _submit,
                child: Text(widget.confirmLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
