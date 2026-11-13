/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/spacing.dart';
import '../util/format.dart';

/// Quantity editor with stepper buttons and an optional unit picker.
///
/// Shared by meal item amounts and stock quantities so both behave the same.
class NexcQuantityField extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String unit;
  final List<String> units;
  final ValueChanged<String>? onUnitChanged;
  final double step;
  final double? min;
  final double? max;
  final bool compact;
  final bool enabled;

  const NexcQuantityField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.unit,
    this.units = const <String>[],
    this.onUnitChanged,
    this.step = 1,
    this.min,
    this.max,
    this.compact = false,
    this.enabled = true,
  });

  @override
  State<NexcQuantityField> createState() => _NexcQuantityFieldState();
}

class _NexcQuantityFieldState extends State<NexcQuantityField> {
  late final TextEditingController _controller = TextEditingController(
    text: formatDecimal(widget.value),
  );

  @override
  void didUpdateWidget(covariant NexcQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String next = formatDecimal(widget.value);
    if (_controller.text != next && !_controller.selection.isValid) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _clamp(double value) {
    double result = value;
    if (widget.min != null && result < widget.min!) result = widget.min!;
    if (widget.max != null && result > widget.max!) result = widget.max!;
    return result;
  }

  void _apply(double next) {
    final double value = _clamp(next);
    _controller.text = formatDecimal(value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double iconSize = widget.compact ? 18 : 20;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NexcSpacing.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: iconSize,
            onPressed: widget.enabled
                ? () => _apply(widget.value - widget.step)
                : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: widget.compact ? 48 : 64,
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: NexcSpacing.sm),
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              onSubmitted: (String text) {
                final double? parsed = double.tryParse(
                  text.replaceAll(',', '.'),
                );
                if (parsed != null) _apply(parsed);
              },
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: iconSize,
            onPressed: widget.enabled
                ? () => _apply(widget.value + widget.step)
                : null,
            icon: const Icon(Icons.add),
          ),
          if (widget.onUnitChanged != null && widget.units.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              initialValue: widget.unit,
              onSelected: widget.onUnitChanged,
              itemBuilder: (BuildContext context) => widget.units
                  .map(
                    (String unit) =>
                        PopupMenuItem<String>(value: unit, child: Text(unit)),
                  )
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NexcSpacing.sm,
                  vertical: NexcSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.unit, style: theme.textTheme.labelLarge),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NexcSpacing.sm),
              child: Text(widget.unit, style: theme.textTheme.labelLarge),
            ),
        ],
      ),
    );
  }
}
