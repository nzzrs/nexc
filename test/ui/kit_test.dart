/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/components/nexc_choice_sheet.dart';
import 'package:nexc_flutter/core/components/nexc_confirm_sheet.dart';
import 'package:nexc_flutter/core/components/nexc_empty_state.dart';
import 'package:nexc_flutter/core/components/nexc_stat_tile.dart';
import 'package:nexc_flutter/core/components/nexc_stepper_field.dart';
import 'package:nexc_flutter/core/components/nexc_tile.dart';
import 'package:nexc_flutter/core/theme/theme.dart';
import 'package:nexc_flutter/core/util/format.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: createNexcTheme(lightColorScheme),
    home: Scaffold(body: child),
  );
}

void main() {
  group('NexcTile', () {
    testWidgets('toggle row flips through the whole surface', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => NexcTile.toggle(
              title: 'Meal tracking',
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Meal tracking'));
      await tester.pump();

      expect(value, isTrue);
    });

    testWidgets('value row exposes the current value', (tester) async {
      await tester.pumpWidget(
        _app(
          NexcTile.value(title: 'Unit system', value: 'Metric', onTap: () {}),
        ),
      );

      expect(find.text('Unit system'), findsOneWidget);
      expect(find.text('Metric'), findsOneWidget);
    });
  });

  group('NexcChoiceSheet', () {
    testWidgets('returns the picked option', (tester) async {
      String? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await NexcChoiceSheet.show<String>(
                  context: context,
                  title: 'Select unit system',
                  selected: 'metric',
                  options: const [
                    NexcChoiceOption(value: 'metric', label: 'Metric'),
                    NexcChoiceOption(value: 'imperial', label: 'Imperial'),
                  ],
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Select unit system'), findsOneWidget);

      await tester.tap(find.text('Imperial'));
      await tester.pumpAndSettle();

      expect(result, 'imperial');
    });
  });

  group('NexcConfirmSheet', () {
    testWidgets('confirms and cancels', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await NexcConfirmSheet.show(
                  context: context,
                  title: 'Delete routine?',
                  message: 'This cannot be undone.',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                  destructive: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('NexcQuantityField', () {
    testWidgets('increments and clamps', (tester) async {
      double value = 1;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => NexcQuantityField(
              value: value,
              unit: 'g',
              step: 5,
              max: 8,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(value, 6);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(value, 8);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(value, 8);
    });
  });

  group('kit renders at 360dp', () {
    testWidgets('no overflow on compact width', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(
          ListView(
            children: [
              NexcTile.toggle(
                title: 'A very long settings label that should wrap nowhere',
                subtitle: 'Supporting text that explains the option',
                value: true,
                onChanged: (_) {},
              ),
              const NexcStatTile(
                label: 'Average session',
                value: '125',
                unit: 'min',
              ),
              const SizedBox(height: 320),
              const NexcEmptyState(
                icon: Icons.inbox,
                title: 'Nothing here yet',
                message: 'Completed sessions will appear here.',
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('format helpers', () {
    test('formatDecimal trims zeros', () {
      expect(formatDecimal(2), '2');
      expect(formatDecimal(2.50), '2.5');
      expect(formatDecimal(2.456, maxDecimals: 2), '2.46');
    });

    test('formatClock pads both fields', () {
      expect(formatClock(95), '01:35');
      expect(formatClock(0), '00:00');
    });

    test('formatDurationShort uses hours and minutes', () {
      expect(formatDurationShort(3900), '1h 05m');
      expect(formatDurationShort(1200), '20m');
    });
  });
}
