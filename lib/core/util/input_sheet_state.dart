/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Behaviour ported from LibreFit's InputModalBottomSheetState.kt
 * (commits 6983ca88, 03a4cb6f).
 */

import 'unit_system.dart';

/// Kind of value edited by an [InputSheetState].
enum InputValueType { load, reps, time }

/// Immutable state of the scroll-wheel input sheet.
///
/// Values are held in the unit shown to the user ([UnitSystem.metric] or
/// [UnitSystem.imperial] for loads, repetitions for reps, seconds for time).
/// [storageValue] converts back to the canonical storage representation:
/// kilograms for loads, an integer count for reps and whole seconds for time.
///
/// All mutations are clamped to [min] and [max] and snapped to the state's
/// step grid, mirroring the upstream Kotlin state holder.
class InputSheetState {
  InputSheetState._({
    required this.type,
    required double value,
    required this.min,
    required this.max,
    required this.step,
    required this.quickStep,
    required this.majorStep,
    this.unitSystem = UnitSystem.metric,
  }) : value = _snap(
         value,
         min: min,
         max: max,
         step: step,
         integer: type != InputValueType.load,
       );

  /// Creates a load state from a canonical kilogram value.
  ///
  /// The wheel moves by 0.5 kg / 1 lb, the small quick buttons by the same
  /// amount and the large quick buttons by 2.5 kg / 5 lb.
  factory InputSheetState.load({
    required double kilograms,
    UnitSystem unitSystem = UnitSystem.metric,
  }) {
    final double displayValue = fromKilograms(kilograms, unitSystem);
    final bool metric = unitSystem == UnitSystem.metric;
    final double step = metric ? 0.5 : 1.0;
    final double majorStep = metric ? 2.5 : 5.0;
    return InputSheetState._(
      type: InputValueType.load,
      value: displayValue,
      min: 0,
      max: 999,
      step: step,
      quickStep: step,
      majorStep: majorStep,
      unitSystem: unitSystem,
    );
  }

  /// Creates a reps state. The wheel moves by one rep, the quick buttons by
  /// one and five reps.
  factory InputSheetState.reps({required int reps}) {
    return InputSheetState._(
      type: InputValueType.reps,
      value: reps.toDouble(),
      min: 0,
      max: 999,
      step: 1,
      quickStep: 1,
      majorStep: 5,
    );
  }

  /// Creates a time state from whole seconds. The wheel moves by one second,
  /// the quick buttons by five and thirty seconds.
  factory InputSheetState.time({required int seconds}) {
    return InputSheetState._(
      type: InputValueType.time,
      value: seconds.toDouble(),
      min: 0,
      max: 3599,
      step: 1,
      quickStep: 5,
      majorStep: 30,
    );
  }

  /// Kind of value edited by this state.
  final InputValueType type;

  /// Current value in display units.
  final double value;

  /// Lowest selectable value in display units.
  final double min;

  /// Highest selectable value in display units.
  final double max;

  /// Wheel increment in display units.
  final double step;

  /// First quick-button increment in display units.
  final double quickStep;

  /// Second quick-button increment in display units.
  final double majorStep;

  /// Unit system used for loads; ignored by reps and time.
  final UnitSystem unitSystem;

  /// Total time in whole seconds.
  int get totalSeconds => value.round();

  /// Minutes part of a time value.
  int get minutes => totalSeconds ~/ 60;

  /// Seconds part of a time value.
  int get seconds => totalSeconds % 60;

  /// Repetition count for a reps value.
  int get reps => value.round();

  /// Canonical storage value: kilograms, reps or seconds.
  num get storageValue {
    switch (type) {
      case InputValueType.load:
        return toKilograms(value, unitSystem);
      case InputValueType.reps:
        return value.round();
      case InputValueType.time:
        return value.round();
    }
  }

  /// Unit suffix shown next to the value (empty for reps and time).
  String get suffix => type == InputValueType.load ? unitSystem.suffix : '';

  /// Title of the input sheet.
  String get title {
    switch (type) {
      case InputValueType.load:
        return 'Weight';
      case InputValueType.reps:
        return 'Reps';
      case InputValueType.time:
        return 'Time';
    }
  }

  /// Current value formatted for display.
  String get formattedValue => formatValue(value);

  /// Every value reachable by the wheel, from [min] to [max] by [step].
  List<double> get options {
    final int count = ((max - min) / step).round();
    return <double>[
      for (int i = 0; i <= count; i++) _roundDisplay(min + i * step, type),
    ];
  }

  /// Formats [raw] the way this state displays values.
  String formatValue(double raw) {
    switch (type) {
      case InputValueType.load:
        return _trimZeros(raw);
      case InputValueType.reps:
        return raw.round().toString();
      case InputValueType.time:
        final int total = raw.round();
        final String minutes = (total ~/ 60).toString().padLeft(2, '0');
        final String seconds = (total % 60).toString().padLeft(2, '0');
        return '$minutes:$seconds';
    }
  }

  /// Returns a copy stepped by [delta] display units, clamped to the range.
  InputSheetState steppedBy(double delta) => withValue(value + delta);

  /// Returns a copy clamped and snapped to the step grid.
  InputSheetState withValue(double raw) {
    return InputSheetState._(
      type: type,
      value: raw,
      min: min,
      max: max,
      step: step,
      quickStep: quickStep,
      majorStep: majorStep,
      unitSystem: unitSystem,
    );
  }

  /// Moves one wheel step forward.
  InputSheetState increment() => steppedBy(step);

  /// Moves one wheel step backwards.
  InputSheetState decrement() => steppedBy(-step);

  /// Moves one small quick-button step forward.
  InputSheetState quickIncrement() => steppedBy(quickStep);

  /// Moves one small quick-button step backwards.
  InputSheetState quickDecrement() => steppedBy(-quickStep);

  /// Moves one large quick-button step forward.
  InputSheetState majorIncrement() => steppedBy(majorStep);

  /// Moves one large quick-button step backwards.
  InputSheetState majorDecrement() => steppedBy(-majorStep);

  static double _snap(
    double raw, {
    required double min,
    required double max,
    required double step,
    required bool integer,
  }) {
    final double clamped = raw.clamp(min, max).toDouble();
    final double snapped = min + ((clamped - min) / step).round() * step;
    final double bounded = snapped.clamp(min, max).toDouble();
    return _roundDisplay(
      integer ? bounded.roundToDouble() : bounded,
      integer ? InputValueType.reps : InputValueType.load,
    );
  }

  static double _roundDisplay(double value, InputValueType type) {
    if (type == InputValueType.load) {
      return double.parse(value.toStringAsFixed(4));
    }
    return value.roundToDouble();
  }

  static String _trimZeros(double value) {
    String text = value.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text == '-0' ? '0' : text;
  }

  @override
  bool operator ==(Object other) {
    return other is InputSheetState &&
        other.type == type &&
        other.value == value &&
        other.min == min &&
        other.max == max &&
        other.step == step &&
        other.quickStep == quickStep &&
        other.majorStep == majorStep &&
        other.unitSystem == unitSystem;
  }

  @override
  int get hashCode => Object.hash(
    type,
    value,
    min,
    max,
    step,
    quickStep,
    majorStep,
    unitSystem,
  );

  @override
  String toString() =>
      'InputSheetState($type, value: $value, unit: $unitSystem)';
}
