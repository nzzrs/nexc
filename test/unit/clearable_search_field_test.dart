/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/components/clearable_search_field.dart';

void main() {
  testWidgets('clear button resets text and notifies empty query', (
    tester,
  ) async {
    final controller = TextEditingController();
    final received = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClearableSearchField(
            controller: controller,
            labelText: 'Search',
            onChanged: received.add,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'bench press');
    await tester.pump();

    expect(controller.text, 'bench press');
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(received.last, isEmpty);
    expect(received, contains('bench press'));
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('prefilled controller shows the clear button', (tester) async {
    final controller = TextEditingController(text: 'squat');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClearableSearchField(
            controller: controller,
            hintText: 'Search exercise...',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });
}
