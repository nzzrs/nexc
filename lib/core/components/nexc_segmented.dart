/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

/// Single-select segmented control used instead of dropdowns for two or three
/// mutually exclusive options.
class NexcSegmented<T> extends StatelessWidget {
  final List<({T value, String label, IconData? icon})> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const NexcSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments
          .map(
            (({T value, String label, IconData? icon}) segment) =>
                ButtonSegment<T>(
                  value: segment.value,
                  label: Text(segment.label),
                  icon: segment.icon == null ? null : Icon(segment.icon),
                ),
          )
          .toList(),
      selected: <T>{selected},
      showSelectedIcon: false,
      onSelectionChanged: (Set<T> selection) {
        if (selection.isNotEmpty) onChanged(selection.first);
      },
    );
  }
}
