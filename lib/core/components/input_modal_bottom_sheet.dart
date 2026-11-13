/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's InputModalBottomSheet.kt
 * (commits 6983ca88, 03a4cb6f, aa84b388).
 */

import 'dart:async';

import 'package:flutter/material.dart';

import '../util/input_sheet_state.dart';

/// Opens the scroll-wheel input sheet and returns the selected value.
///
/// The result is in canonical storage units: kilograms for loads, an integer
/// rep count for reps and whole seconds for time. A cancelled sheet returns
/// null. When [dismissAutomatically] is true the sheet closes shortly after
/// the last interaction and saves the current value.
Future<num?> showInputModalBottomSheet(
  BuildContext context, {
  required InputSheetState state,
  bool dismissAutomatically = true,
}) {
  return showModalBottomSheet<num>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => InputModalBottomSheet(
      initialState: state,
      dismissAutomatically: dismissAutomatically,
    ),
  );
}

/// Modal sheet that edits a load, rep count or duration with a scroll wheel.
class InputModalBottomSheet extends StatefulWidget {
  const InputModalBottomSheet({
    super.key,
    required this.initialState,
    this.dismissAutomatically = true,
    this.autoDismissDelay = const Duration(milliseconds: 1500),
  });

  /// Value shown when the sheet opens.
  final InputSheetState initialState;

  /// Whether inactivity closes the sheet after [autoDismissDelay].
  final bool dismissAutomatically;

  /// Time without interaction before an automatic dismissal.
  final Duration autoDismissDelay;

  @override
  State<InputModalBottomSheet> createState() => _InputModalBottomSheetState();
}

class _InputModalBottomSheetState extends State<InputModalBottomSheet> {
  late InputSheetState _state;
  late final FixedExtentScrollController _wheelController;
  Timer? _dismissTimer;
  bool _syncingWheel = false;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _wheelController = FixedExtentScrollController(
      initialItem: _indexOf(_state.value),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _wheelController.dispose();
    super.dispose();
  }

  int _indexOf(double value) {
    final int index = ((value - _state.min) / _state.step).round();
    return index.clamp(0, _state.options.length - 1);
  }

  void _apply(InputSheetState next) {
    if (next == _state) return;
    setState(() => _state = next);
    _restartDismissTimer();

    final int index = _indexOf(next.value);
    if (_wheelController.hasClients && _wheelController.selectedItem != index) {
      _syncingWheel = true;
      _wheelController.jumpToItem(index);
      _syncingWheel = false;
    }
  }

  void _onWheelChanged(int index) {
    if (_syncingWheel) return;
    final List<double> options = _state.options;
    if (index < 0 || index >= options.length) return;
    _apply(_state.withValue(options[index]));
  }

  void _restartDismissTimer() {
    _dismissTimer?.cancel();
    if (!widget.dismissAutomatically) return;
    _dismissTimer = Timer(widget.autoDismissDelay, () {
      if (!mounted) return;
      Navigator.of(context).pop(_state.storageValue);
    });
  }

  void _confirm() {
    _dismissTimer?.cancel();
    Navigator.of(context).pop(_state.storageValue);
  }

  void _cancel() {
    _dismissTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _amountLabel(double amount) => _state.formatValue(amount);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String suffix = _state.suffix;
    final String valueText = suffix.isEmpty
        ? _state.formattedValue
        : '${_state.formattedValue} $suffix';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _state.title,
              key: const ValueKey<String>('input-sheet-title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valueText,
              key: const ValueKey<String>('input-sheet-value'),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListWheelScrollView.useDelegate(
                key: const ValueKey<String>('input-sheet-wheel'),
                controller: _wheelController,
                itemExtent: 44,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: _onWheelChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _state.options.length,
                  builder: (BuildContext context, int index) {
                    final double option = _state.options[index];
                    final bool selected = option == _state.value;
                    return Center(
                      child: Text(
                        _state.formatValue(option),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const ValueKey<String>('input-sheet-decrement'),
                  tooltip: 'Decrease by ${_amountLabel(_state.quickStep)}',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _apply(_state.quickDecrement()),
                ),
                const SizedBox(width: 16),
                IconButton(
                  key: const ValueKey<String>('input-sheet-increment'),
                  tooltip: 'Increase by ${_amountLabel(_state.quickStep)}',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _apply(_state.quickIncrement()),
                ),
                const SizedBox(width: 32),
                IconButton(
                  key: const ValueKey<String>('input-sheet-quick-decrement'),
                  tooltip: 'Decrease by ${_amountLabel(_state.majorStep)}',
                  icon: const Icon(Icons.keyboard_double_arrow_left),
                  onPressed: () => _apply(_state.majorDecrement()),
                ),
                const SizedBox(width: 16),
                IconButton(
                  key: const ValueKey<String>('input-sheet-quick-increment'),
                  tooltip: 'Increase by ${_amountLabel(_state.majorStep)}',
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  onPressed: () => _apply(_state.majorIncrement()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: const ValueKey<String>('input-sheet-cancel'),
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey<String>('input-sheet-confirm'),
                  onPressed: _confirm,
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
