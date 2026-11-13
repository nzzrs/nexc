/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/features/workout/workout_screen.dart';

void main() {
  Future<void> pumpLauncher(
    WidgetTester tester,
    void Function(bool) onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                onResult(await showUpdateRoutineDialog(context));
              },
              child: const Text('open dialog'),
            ),
          ),
        ),
      ),
    );
  }

  group('showUpdateRoutineDialog', () {
    testWidgets('returns true when the user chooses Update', (tester) async {
      bool? result;
      await pumpLauncher(tester, (value) => result = value);

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Update routine?'), findsOneWidget);
      expect(find.text("Don't update"), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Update routine?'), findsNothing);
    });

    testWidgets('returns false when the user chooses Don\'t update', (
      tester,
    ) async {
      bool? result;
      await pumpLauncher(tester, (value) => result = value);

      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Don't update"));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
