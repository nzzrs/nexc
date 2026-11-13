/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Shared search field with a reliable clear action.
 */

import 'package:flutter/material.dart';

/// Text field used by every search surface in the app.
///
/// The clear button resets both the controller and the owning widget state,
/// so pressing it always clears the visible query and the filtered results.
class ClearableSearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? labelText;
  final String? hintText;
  final IconData prefixIcon;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;

  const ClearableSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.prefixIcon = Icons.search,
    this.autofocus = false,
    this.contentPadding,
    this.enabled = true,
  });

  @override
  State<ClearableSearchField> createState() => _ClearableSearchFieldState();
}

class _ClearableSearchFieldState extends State<ClearableSearchField> {
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_syncFromController);
  }

  @override
  void didUpdateWidget(covariant ClearableSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  void _syncFromController() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText == _hasText || !mounted) return;
    setState(() {
      _hasText = hasText;
    });
  }

  void _onChanged(String value) {
    if (value.isNotEmpty != _hasText) {
      setState(() {
        _hasText = value.isNotEmpty;
      });
    }
    widget.onChanged(value);
  }

  void _clear() {
    widget.controller.clear();
    if (_hasText) {
      setState(() {
        _hasText = false;
      });
    }
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: _clear,
              )
            : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        contentPadding: widget.contentPadding,
      ),
      onChanged: _onChanged,
    );
  }
}
