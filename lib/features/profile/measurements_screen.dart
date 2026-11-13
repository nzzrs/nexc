/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_chart_card.dart';
import '../../core/components/nexc_confirm_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_segmented.dart';
import '../../core/components/nexc_stat_tile.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/app_database.dart';
import '../../core/db/measurement_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/profile_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../../core/util/unit_system.dart';
import '../../l10n/app_localizations.dart';

import 'log_measurement_screen.dart';

/// Converts body-weight chart spots stored in kilograms to [system].
///
/// Metric spots are returned untouched; imperial spots are converted for
/// rendering so the chart axis and tooltips share the selected unit.
List<FlSpot> convertWeightSpots(List<FlSpot> spots, UnitSystem system) {
  if (system == UnitSystem.metric) return spots;
  return spots
      .map((spot) => FlSpot(spot.x, fromKilograms(spot.y, system)))
      .toList();
}

String formatDoubleHours(double hours) {
  final totalMinutes = (hours * 60).round();
  final hrs = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (hrs > 0) {
    if (mins > 0) {
      return '${hrs}h ${mins}m';
    }
    return '${hrs}h';
  }
  return '${mins}m';
}

/// Measurement categories shown as tabs.
enum _HealthTab { body, sleep, activity }

/// One metric plotted on a [NexcChartCard].
class _ChartSeries {
  const _ChartSeries({
    required this.title,
    required this.unit,
    required this.spots,
    required this.dates,
  });

  final String title;
  final String unit;
  final List<FlSpot> spots;
  final List<DateTime> dates;

  double get latest => spots.last.y;

  double get average =>
      spots.fold<double>(0, (double sum, FlSpot spot) => sum + spot.y) /
      spots.length;

  double get minValue => spots.map((FlSpot spot) => spot.y).reduce(math.min);

  double get maxValue => spots.map((FlSpot spot) => spot.y).reduce(math.max);
}

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  final Map<_HealthTab, int> _metricIndex = <_HealthTab, int>{};

  void _openLogMeasurement() {
    final l10n = context.l10n;
    Navigator.push(
      context,
      NexcPage.route<void>(
        title: l10n.logMeasurement,
        builder: (BuildContext context) => const LogMeasurementScreen(),
      ),
    );
  }

  String _tabLabel(_HealthTab tab) {
    final l10n = context.l10n;
    switch (tab) {
      case _HealthTab.body:
        return l10n.measurementTabBody;
      case _HealthTab.sleep:
        return l10n.measurementTabSleep;
      case _HealthTab.activity:
        return l10n.measurementTabActivity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = context.l10n;
    final List<_HealthTab> tabs = <_HealthTab>[
      _HealthTab.body,
      if (settings.enableSleep) _HealthTab.sleep,
      if (settings.enableActivity) _HealthTab.activity,
    ];

    return DefaultTabController(
      length: tabs.length,
      child: NexcPage(
        title: l10n.measurementsTitle,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openLogMeasurement,
          icon: const Icon(NexcIcons.add),
          label: Text(l10n.addLog),
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final _HealthTab tab in tabs) Tab(text: _tabLabel(tab)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final _HealthTab tab in tabs) _buildTab(tab, settings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(_HealthTab tab, SettingsState settings) {
    switch (tab) {
      case _HealthTab.body:
        return NexcAsyncView<List<BodyMeasurement>>(
          value: ref.watch(allMeasurementsProvider),
          onRetry: () => ref.invalidate(allMeasurementsProvider),
          errorTitle: (Object error) => context.l10n.errorWithMessage('$error'),
          builder: (List<BodyMeasurement> weightLogs) =>
              NexcAsyncView<List<AdvancedBodyMeasurement>>(
                value: ref.watch(allAdvancedBodyMeasurementsProvider),
                onRetry: () =>
                    ref.invalidate(allAdvancedBodyMeasurementsProvider),
                errorTitle: (Object error) =>
                    context.l10n.errorWithMessage('$error'),
                builder: (List<AdvancedBodyMeasurement> advancedLogs) =>
                    _buildBodyTab(weightLogs, advancedLogs, settings),
              ),
        );
      case _HealthTab.sleep:
        return NexcAsyncView<List<SleepMeasurement>>(
          value: ref.watch(allSleepMeasurementsProvider),
          onRetry: () => ref.invalidate(allSleepMeasurementsProvider),
          errorTitle: (Object error) => context.l10n.errorWithMessage('$error'),
          builder: (List<SleepMeasurement> sleepLogs) =>
              NexcAsyncView<List<AdvancedSleepMeasurement>>(
                value: ref.watch(allAdvancedSleepMeasurementsProvider),
                onRetry: () =>
                    ref.invalidate(allAdvancedSleepMeasurementsProvider),
                errorTitle: (Object error) =>
                    context.l10n.errorWithMessage('$error'),
                builder: (List<AdvancedSleepMeasurement> advancedLogs) =>
                    _buildSleepTab(sleepLogs, advancedLogs, settings),
              ),
        );
      case _HealthTab.activity:
        return NexcAsyncView<List<ActivityMeasurement>>(
          value: ref.watch(allActivityMeasurementsProvider),
          onRetry: () => ref.invalidate(allActivityMeasurementsProvider),
          errorTitle: (Object error) => context.l10n.errorWithMessage('$error'),
          builder: (List<ActivityMeasurement> logs) => _buildActivityTab(logs),
        );
    }
  }

  Widget _buildBodyTab(
    List<BodyMeasurement> weightLogs,
    List<AdvancedBodyMeasurement> advancedBodyLogs,
    SettingsState settings,
  ) {
    final l10n = context.l10n;
    final UnitSystem unitSystem = settings.unitSystem;
    final String weightUnit = unitSystem == UnitSystem.imperial
        ? l10n.unitLb
        : l10n.unitKg;

    final List<BodyMeasurement> chronologicalWeight = weightLogs.reversed
        .toList();
    final List<_ChartSeries> series = <_ChartSeries>[
      _ChartSeries(
        title: l10n.weightProgress,
        unit: weightUnit,
        spots: convertWeightSpots(
          chronologicalWeight
              .asMap()
              .entries
              .map(
                (MapEntry<int, BodyMeasurement> entry) =>
                    FlSpot(entry.key.toDouble(), entry.value.bodyWeight),
              )
              .toList(),
          unitSystem,
        ),
        dates: chronologicalWeight
            .map((BodyMeasurement log) => log.date)
            .toList(),
      ),
    ];

    if (settings.enableAdvancedBody) {
      series.addAll(
        _advancedBodySeries(
          advancedBodyLogs,
          bodyFatUnit: '%',
          waistUnit: l10n.unitCm,
        ),
      );
    }

    final List<Widget> history = <Widget>[
      for (final BodyMeasurement log in weightLogs)
        NexcTile(
          title: l10n.weightWithValue(
            formatWeight(log.bodyWeight, unitSystem, suffix: weightUnit),
          ),
          subtitle: l10n.dateWithValue(context.formatShortDate(log.date)),
          trailing: _deleteButton(
            message: l10n.deleteWeightConfirm,
            onConfirm: () =>
                ref.read(measurementRepositoryProvider).deleteMeasurement(log),
          ),
        ),
      if (settings.enableAdvancedBody)
        for (final AdvancedBodyMeasurement log in advancedBodyLogs)
          NexcTile(
            title: _advancedBodySummary(log, l10n),
            subtitle: l10n.dateWithValue(context.formatShortDate(log.date)),
            trailing: _deleteButton(
              message: l10n.deleteAdvancedBodyConfirm,
              onConfirm: () => ref
                  .read(measurementRepositoryProvider)
                  .deleteAdvancedBodyMeasurement(log),
            ),
          ),
    ];

    return _tabContent(
      tab: _HealthTab.body,
      series: series,
      historyTitle: l10n.bodyHistory,
      emptyState: NexcEmptyState(
        icon: NexcIcons.measurements,
        title: l10n.noBodyMeasurements,
        actionLabel: l10n.addLog,
        onAction: _openLogMeasurement,
      ),
      history: history,
    );
  }

  List<_ChartSeries> _advancedBodySeries(
    List<AdvancedBodyMeasurement> logs, {
    required String bodyFatUnit,
    required String waistUnit,
  }) {
    final l10n = context.l10n;
    final List<_ChartSeries> series = <_ChartSeries>[];

    _addSeries(
      series,
      logs
          .where((AdvancedBodyMeasurement l) => l.bodyFatPercentage != null)
          .toList(),
      title: l10n.bodyFatPercent,
      unit: bodyFatUnit,
      value: (AdvancedBodyMeasurement l) => l.bodyFatPercentage!.toDouble(),
      date: (AdvancedBodyMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs
          .where((AdvancedBodyMeasurement l) => l.muscleMassPercentage != null)
          .toList(),
      title: l10n.muscleMassPercent,
      unit: bodyFatUnit,
      value: (AdvancedBodyMeasurement l) => l.muscleMassPercentage!.toDouble(),
      date: (AdvancedBodyMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs
          .where((AdvancedBodyMeasurement l) => l.waistCircumference != null)
          .toList(),
      title: l10n.waistCircumference,
      unit: waistUnit,
      value: (AdvancedBodyMeasurement l) => l.waistCircumference!,
      date: (AdvancedBodyMeasurement l) => l.date,
    );
    return series;
  }

  void _addSeries<T>(
    List<_ChartSeries> target,
    List<T> logs, {
    required String title,
    required String unit,
    required double Function(T log) value,
    required DateTime Function(T log) date,
  }) {
    final List<T> chronological = logs.reversed.toList();
    target.add(
      _ChartSeries(
        title: title,
        unit: unit,
        spots: chronological
            .asMap()
            .entries
            .map(
              (MapEntry<int, T> entry) =>
                  FlSpot(entry.key.toDouble(), value(entry.value)),
            )
            .toList(),
        dates: chronological.map(date).toList(),
      ),
    );
  }

  Widget _buildSleepTab(
    List<SleepMeasurement> sleepLogs,
    List<AdvancedSleepMeasurement> advancedSleepLogs,
    SettingsState settings,
  ) {
    final l10n = context.l10n;
    final String hrsUnit = l10n.hrsShort;
    final List<_ChartSeries> series = <_ChartSeries>[];

    _addSeries(
      series,
      sleepLogs.where((SleepMeasurement l) => l.sleepDuration != null).toList(),
      title: l10n.sleepDuration,
      unit: hrsUnit,
      value: (SleepMeasurement l) => l.sleepDuration!,
      date: (SleepMeasurement l) => l.date,
    );
    _addSeries(
      series,
      sleepLogs.where((SleepMeasurement l) => l.sleepingRHR != null).toList(),
      title: l10n.sleepingRhr,
      unit: l10n.unitBpm,
      value: (SleepMeasurement l) => l.sleepingRHR!.toDouble(),
      date: (SleepMeasurement l) => l.date,
    );
    _addSeries(
      series,
      sleepLogs.where((SleepMeasurement l) => l.sleepingHRV != null).toList(),
      title: l10n.sleepingHrv,
      unit: l10n.unitMs,
      value: (SleepMeasurement l) => l.sleepingHRV!.toDouble(),
      date: (SleepMeasurement l) => l.date,
    );

    if (settings.enableAdvancedSleep) {
      _addSeries(
        series,
        advancedSleepLogs
            .where((AdvancedSleepMeasurement l) => l.totalAwakeTime != null)
            .toList(),
        title: l10n.timeAwake,
        unit: hrsUnit,
        value: (AdvancedSleepMeasurement l) => l.totalAwakeTime!,
        date: (AdvancedSleepMeasurement l) => l.date,
      );
      _addSeries(
        series,
        advancedSleepLogs
            .where((AdvancedSleepMeasurement l) => l.timeInBed != null)
            .toList(),
        title: l10n.timeInBed,
        unit: hrsUnit,
        value: (AdvancedSleepMeasurement l) => l.timeInBed!,
        date: (AdvancedSleepMeasurement l) => l.date,
      );
      _addSeries(
        series,
        advancedSleepLogs
            .where((AdvancedSleepMeasurement l) => l.numberOfAwakenings != null)
            .toList(),
        title: l10n.numberOfAwakenings,
        unit: '',
        value: (AdvancedSleepMeasurement l) => l.numberOfAwakenings!.toDouble(),
        date: (AdvancedSleepMeasurement l) => l.date,
      );
    }

    final List<Widget> history = <Widget>[
      for (final SleepMeasurement log in sleepLogs)
        NexcTile(
          title: _sleepSummary(log, l10n),
          subtitle: l10n.dateWithValue(context.formatShortDate(log.date)),
          trailing: _deleteButton(
            message: l10n.deleteSleepConfirm,
            onConfirm: () => ref
                .read(measurementRepositoryProvider)
                .deleteSleepMeasurement(log),
          ),
        ),
      if (settings.enableAdvancedSleep)
        for (final AdvancedSleepMeasurement log in advancedSleepLogs)
          NexcTile(
            title: _advancedSleepSummary(log, l10n),
            subtitle: l10n.dateWithValue(context.formatShortDate(log.date)),
            trailing: _deleteButton(
              message: l10n.deleteAdvancedSleepConfirm,
              onConfirm: () => ref
                  .read(measurementRepositoryProvider)
                  .deleteAdvancedSleepMeasurement(log),
            ),
          ),
    ];

    return _tabContent(
      tab: _HealthTab.sleep,
      series: series,
      historyTitle: l10n.sleepHistory,
      emptyState: NexcEmptyState(
        icon: NexcIcons.restAlerts,
        title: l10n.noSleepLogs,
        actionLabel: l10n.addLog,
        onAction: _openLogMeasurement,
      ),
      history: history,
    );
  }

  Widget _buildActivityTab(List<ActivityMeasurement> logs) {
    final l10n = context.l10n;
    final List<_ChartSeries> series = <_ChartSeries>[];

    _addSeries(
      series,
      logs.where((ActivityMeasurement l) => l.dailySteps != null).toList(),
      title: l10n.dailySteps,
      unit: l10n.unitSteps,
      value: (ActivityMeasurement l) => l.dailySteps!.toDouble(),
      date: (ActivityMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs
          .where((ActivityMeasurement l) => l.activeEnergyBurned != null)
          .toList(),
      title: l10n.caloriesActive,
      unit: l10n.unitKcal,
      value: (ActivityMeasurement l) => l.activeEnergyBurned!,
      date: (ActivityMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs.where((ActivityMeasurement l) => l.vo2Max != null).toList(),
      title: l10n.vo2Max,
      unit: '${l10n.unitMl}/${l10n.unitKg}',
      value: (ActivityMeasurement l) => l.vo2Max!,
      date: (ActivityMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs.where((ActivityMeasurement l) => l.wakingRHR != null).toList(),
      title: l10n.wakingRhr,
      unit: l10n.unitBpm,
      value: (ActivityMeasurement l) => l.wakingRHR!.toDouble(),
      date: (ActivityMeasurement l) => l.date,
    );
    _addSeries(
      series,
      logs.where((ActivityMeasurement l) => l.wakingHRV != null).toList(),
      title: l10n.wakingHrv,
      unit: l10n.unitMs,
      value: (ActivityMeasurement l) => l.wakingHRV!.toDouble(),
      date: (ActivityMeasurement l) => l.date,
    );

    final List<Widget> history = <Widget>[
      for (final ActivityMeasurement log in logs)
        NexcTile(
          title: _activitySummary(log, l10n),
          subtitle: l10n.dateWithValue(context.formatShortDate(log.date)),
          trailing: _deleteButton(
            message: l10n.deleteActivityConfirm,
            onConfirm: () => ref
                .read(measurementRepositoryProvider)
                .deleteActivityMeasurement(log),
          ),
        ),
    ];

    return _tabContent(
      tab: _HealthTab.activity,
      series: series,
      historyTitle: l10n.activityHistory,
      emptyState: NexcEmptyState(
        icon: NexcIcons.workout,
        title: l10n.noActivityLogs,
        actionLabel: l10n.addLog,
        onAction: _openLogMeasurement,
      ),
      history: history,
    );
  }

  Widget _tabContent({
    required _HealthTab tab,
    required List<_ChartSeries> series,
    required String historyTitle,
    required Widget emptyState,
    required List<Widget> history,
  }) {
    final List<_ChartSeries> chartable = series
        .where((_ChartSeries entry) => entry.spots.length >= 2)
        .toList();
    final _ChartSeries? selected = chartable.isEmpty
        ? null
        : chartable[math.min(
            math.max(_metricIndex[tab] ?? 0, 0),
            chartable.length - 1,
          )];

    return ListView(
      padding: const EdgeInsets.only(bottom: NexcSpacing.section * 2),
      children: [
        if (selected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NexcSpacing.lg,
              NexcSpacing.md,
              NexcSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (chartable.length > 1) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: NexcSegmented<int>(
                      selected: chartable.indexOf(selected),
                      segments: [
                        for (int i = 0; i < chartable.length; i++)
                          (value: i, label: chartable[i].title, icon: null),
                      ],
                      onChanged: (int index) =>
                          setState(() => _metricIndex[tab] = index),
                    ),
                  ),
                  const SizedBox(height: NexcSpacing.md),
                ],
                _chartCard(selected),
              ],
            ),
          ),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: NexcSpacing.xl),
            child: emptyState,
          )
        else
          NexcSection(title: historyTitle, children: history),
      ],
    );
  }

  Widget _chartCard(_ChartSeries series) {
    final ThemeData theme = Theme.of(context);
    final String range = series.dates.length >= 2
        ? context.formatDateRange(series.dates.first, series.dates.last)
        : '';

    return NexcChartCard(
      title: series.title,
      subtitle: range.isEmpty ? null : range,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NexcStatTile(
            label: context.l10n.latestLabel,
            value: formatDecimal(series.latest, maxDecimals: 1),
            unit: series.unit,
          ),
          const SizedBox(height: NexcSpacing.sm),
          NexcStatTile(
            label: context.l10n.averageLabel,
            value: formatDecimal(series.average, maxDecimals: 1),
            unit: series.unit,
          ),
          const SizedBox(height: NexcSpacing.sm),
          NexcStatTile(
            label: context.l10n.minMaxLabel,
            value:
                '${formatDecimal(series.minValue, maxDecimals: 1)} - '
                '${formatDecimal(series.maxValue, maxDecimals: 1)}',
            unit: series.unit,
          ),
          const SizedBox(height: NexcSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(right: NexcSpacing.xl),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (double value) => FlLine(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      strokeWidth: 1,
                      dashArray: <int>[4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: series.spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (
                              FlSpot spot,
                              double percent,
                              LineChartBarData barData,
                              int index,
                            ) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: theme.colorScheme.primary,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.onPrimary,
                              );
                            },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: <Color>[
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SizedBox(
                            width: 40,
                            child: Text(
                              formatDecimal(value, maxDecimals: 1),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.round();
                          if (index < 0 || index >= series.dates.length) {
                            return const SizedBox.shrink();
                          }
                          final int step = math.max(
                            1,
                            (series.dates.length / 4).ceil(),
                          );
                          if (index % step != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: NexcSpacing.xs),
                            child: SizedBox(
                              width: 56,
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatShortMonthDay(series.dates[index]),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot touchedSpot) =>
                          theme.colorScheme.secondaryContainer,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          final String unit = series.unit.isEmpty
                              ? ''
                              : ' ${series.unit}';
                          return LineTooltipItem(
                            '${formatDecimal(spot.y, maxDecimals: 1)}$unit',
                            theme.textTheme.labelMedium!.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteButton({
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    final ThemeData theme = Theme.of(context);
    return IconButton(
      tooltip: context.l10n.delete,
      icon: Icon(NexcIcons.delete, color: theme.colorScheme.error),
      onPressed: () => _confirmDelete(message: message, onConfirm: onConfirm),
    );
  }

  Future<void> _confirmDelete({
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final l10n = context.l10n;
    final bool? confirmed = await NexcConfirmSheet.show(
      context: context,
      title: l10n.deleteLog,
      message: message,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true) {
      await onConfirm();
    }
  }

  String _advancedBodySummary(
    AdvancedBodyMeasurement log,
    AppLocalizations l10n,
  ) {
    final List<String> details = <String>[
      if (log.bodyFatPercentage != null)
        l10n.bodyFatValue('${log.bodyFatPercentage}'),
      if (log.muscleMassPercentage != null)
        l10n.muscleMassValue('${log.muscleMassPercentage}'),
      if (log.waistCircumference != null)
        l10n.waistValue(formatDecimal(log.waistCircumference!)),
    ];
    return details.isEmpty ? l10n.advancedEntry : details.join(', ');
  }

  String _sleepSummary(SleepMeasurement log, AppLocalizations l10n) {
    final List<String> details = <String>[
      if (log.sleepDuration != null) formatDoubleHours(log.sleepDuration!),
      if (log.sleepingRHR != null) l10n.sleepingRhrValue('${log.sleepingRHR}'),
      if (log.sleepingHRV != null) l10n.sleepingHrvValue('${log.sleepingHRV}'),
    ];
    return details.isEmpty ? l10n.sleepEntry : details.join(', ');
  }

  String _advancedSleepSummary(
    AdvancedSleepMeasurement log,
    AppLocalizations l10n,
  ) {
    final List<String> details = <String>[
      if (log.timeInBed != null)
        l10n.sleepMetricBed(formatDoubleHours(log.timeInBed!)),
      if (log.totalAwakeTime != null)
        l10n.sleepMetricAwake(formatDoubleHours(log.totalAwakeTime!)),
      if (log.longestAwakePeriod != null)
        l10n.sleepMetricLongestAwake(
          formatDoubleHours(log.longestAwakePeriod!),
        ),
      if (log.numberOfAwakenings != null)
        l10n.awakeningsCount(log.numberOfAwakenings!),
    ];
    return details.isEmpty ? l10n.advSleepEntry : details.join(', ');
  }

  String _activitySummary(ActivityMeasurement log, AppLocalizations l10n) {
    final List<String> details = <String>[
      if (log.dailySteps != null) l10n.stepsCount('${log.dailySteps}'),
      if (log.activeEnergyBurned != null)
        l10n.kcalValue(formatDecimal(log.activeEnergyBurned!)),
      if (log.vo2Max != null) l10n.vo2WithValue(formatDecimal(log.vo2Max!)),
      if (log.wakingRHR != null) l10n.wakingRhrValue('${log.wakingRHR}'),
      if (log.wakingHRV != null) l10n.wakingHrvValue('${log.wakingHRV}'),
    ];
    return details.isEmpty ? l10n.activityEntry : details.join(', ');
  }
}
