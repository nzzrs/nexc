/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/components/nexc_macro.dart';
import 'package:nexc_flutter/core/components/nexc_stepper_field.dart';
import 'package:nexc_flutter/core/db/enums.dart';
import 'package:nexc_flutter/core/db/relations.dart';
import 'package:nexc_flutter/core/providers/meals_providers.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/theme/theme.dart';
import 'package:nexc_flutter/features/meals/add_meal_item_screen.dart';
import 'package:nexc_flutter/features/meals/meals_dashboard_screen.dart';
import 'package:nexc_flutter/features/meals/track_meal_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int _planId = 11;
const int _productId = 21;

Product _product() {
  return const Product(
    id: _productId,
    name: 'Oats',
    defaultUnits: 'g',
    edibleQtyPerUnit: 1,
    kcal: 380,
    proteins: 12,
    carbsAvailable: 60,
    fats: 8,
    isSupplement: false,
    isPortable: true,
    isStockRaw: false,
  );
}

/// One active plan with a single breakfast meal holding one product.
MealPlanWithMealsAndItems _plan() {
  final DateTime now = DateTime.now();
  return MealPlanWithMealsAndItems(
    mealPlan: MealPlan(
      id: _planId,
      parentPlanId: 0,
      title: 'Training day',
      notes: '',
      state: MealPlanState.ACTIVE,
      created: now,
      completed: now,
      isTemporal: false,
      targetProtein: 150,
      targetCarbs: 200,
      targetFats: 70,
    ),
    meals: [
      MealWithItems(
        meal: Meal(
          id: 5,
          mealPlanId: _planId,
          name: 'Breakfast',
          time: const LocalTime(8, 0),
          notes: '',
          position: 0,
          atHome: true,
        ),
        items: [
          MealItemWithDetails(
            mealItem: MealItem(
              id: 7,
              mealId: 5,
              type: MealItemType.PRODUCT,
              targetId: _productId,
              amount: 100,
              amountUnit: AmountUnit.GRAMS,
              consumed: false,
              position: 0,
            ),
            product: _product(),
          ),
        ],
      ),
    ],
  );
}

List<Override> _mealsOverrides() {
  final MealPlanWithMealsAndItems plan = _plan();
  return [
    todayMealPlanProvider.overrideWith(
      (Ref ref) => Stream<MealPlanWithMealsAndItems?>.value(plan),
    ),
    mealTemplatesProvider.overrideWith(
      (Ref ref) => Stream<List<MealPlanWithMealsAndItems>>.value([plan]),
    ),
    allProductsProvider.overrideWith(
      (Ref ref) => Stream<List<Product>>.value([_product()]),
    ),
    allRecipesProvider.overrideWith(
      (Ref ref) => Stream<List<RecipeWithIngredients>>.value(
        const <RecipeWithIngredients>[],
      ),
    ),
    productUsageCountsProvider.overrideWith(
      (Ref ref) => Stream<Map<int, int>>.value(const <int, int>{}),
    ),
    inStockProductIdsProvider.overrideWith(
      (Ref ref) => Stream<Set<int>>.value(const <int>{}),
    ),
  ];
}

Widget _app(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    theme: createNexcTheme(lightColorScheme),
    builder: (BuildContext context, Widget? widget) {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
          textScaler: TextScaler.linear(textScale),
          size: const Size(360, 640),
        ),
        child: widget!,
      );
    },
    home: child,
  );
}

Future<Widget> _scope(
  Widget child, {
  List<Override> overrides = const <Override>[],
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      ...overrides,
    ],
    child: _app(child, textScale: textScale),
  );
}

void main() {
  testWidgets('dashboard shows macro ring and target bars', (tester) async {
    await tester.pumpWidget(
      await _scope(
        const MealsDashboardScreen(),
        overrides: _mealsOverrides(),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NexcMacroRing), findsOneWidget);
    expect(find.byType(NexcMacroBar), findsNWidgets(3));
    expect(find.text("Today's Macros"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard exposes one contextual action button', (tester) async {
    await tester.pumpWidget(
      await _scope(const MealsDashboardScreen(), overrides: _mealsOverrides()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add Item to Meal'), findsOneWidget);
    expect(find.text('Add Snack'), findsOneWidget);
    expect(find.text('Create Meal Plan'), findsOneWidget);
  });

  testWidgets('meal card expands to reveal its items', (tester) async {
    await tester.pumpWidget(
      await _scope(
        const MealsDashboardScreen(),
        overrides: _mealsOverrides(),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oats'), findsNothing);

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    expect(find.text('Oats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add item screen keeps amount per selected item', (tester) async {
    await tester.pumpWidget(
      await _scope(
        AddMealItemScreen(
          products: [_product()],
          recipes: const <RecipeWithIngredients>[],
        ),
        overrides: _mealsOverrides(),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oats'));
    await tester.pumpAndSettle();
    expect(find.textContaining('100 g'), findsOneWidget);

    await tester.tap(find.textContaining('100 g'));
    await tester.pumpAndSettle();
    expect(find.byType(NexcQuantityField), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NexcQuantityField),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.textContaining('101 g'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('track plan renders without overflow at 360dp', (tester) async {
    await tester.pumpWidget(
      await _scope(
        const TrackMealPlanScreen(mealPlanId: _planId),
        overrides: [
          ..._mealsOverrides(),
          mealPlanStreamProvider(_planId).overrideWith(
            (Ref ref) => Stream<MealPlanWithMealsAndItems?>.value(_plan()),
          ),
        ],
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Training day'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Oats'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
