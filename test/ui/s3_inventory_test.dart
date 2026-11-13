/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/db/stock_repository.dart';
import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:nexc_flutter/core/theme/theme.dart';
import 'package:nexc_flutter/features/meals/products_library_screen.dart';
import 'package:nexc_flutter/features/meals/recipes_library_screen.dart';
import 'package:nexc_flutter/features/stock/receipt_review_screen.dart';
import 'package:nexc_flutter/features/stock/stock_screen.dart';

/// Tears the tree down and lets drift's pending stream timers fire before the
/// test binding checks for leftovers.
Future<void> _drainDatabase(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}

Widget _app({
  required AppDatabase db,
  required SharedPreferences prefs,
  required Widget home,
}) {
  return ProviderScope(
    overrides: <Override>[
      dbProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp(theme: createNexcTheme(lightColorScheme), home: home),
  );
}

Future<int> _product(
  AppDatabase db, {
  required String name,
  String defaultUnits = 'g',
  int? mlToGFactor,
  int? unitWeight,
  bool isPortable = true,
}) {
  return db
      .into(db.products)
      .insert(
        ProductsCompanion.insert(
          name: name,
          proteins: 5,
          fats: 2,
          isSupplement: false,
          defaultUnits: Value(defaultUnits),
          edibleQtyPerUnit: const Value(1.0),
          mlToGFactor: Value(mlToGFactor),
          unitWeight: Value(unitWeight),
          isPortable: Value(isPortable),
        ),
      );
}

Future<int> _house(AppDatabase db) {
  return db.into(db.houses).insert(HousesCompanion.insert(name: 'Home'));
}

StockWithProduct _stock({
  required int productId,
  required String name,
  required double quantity,
  double? trigger,
}) {
  return StockWithProduct(
    stock: ProductStock(
      id: productId,
      productId: productId,
      houseId: 1,
      quantity: quantity,
      minTriggerQuantity: trigger,
      quantityGrams: quantity,
      quantityMl: quantity,
      quantityUnits: quantity,
    ),
    product: Product(
      id: productId,
      name: name,
      defaultUnits: 'g',
      edibleQtyPerUnit: 1.0,
      proteins: 1,
      fats: 1,
      isSupplement: false,
      isPortable: true,
      isStockRaw: false,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product library', () {
    testWidgets('rows show stock badge and the sort menu', (tester) async {
      final SharedPreferences prefs = await _prefs();
      final AppDatabase db = AppDatabase.executor(NativeDatabase.memory());
      final int houseId = await _house(db);
      final int inStockId = await _product(db, name: 'Greek Yogurt');
      await _product(db, name: 'Oats');
      final StockRepository stockRepo = StockRepository(db);
      await stockRepo.saveStock(
        productId: inStockId,
        houseId: houseId,
        quantity: 500,
        minTriggerQuantity: null,
      );

      await tester.pumpWidget(
        _app(db: db, prefs: prefs, home: const ProductsLibraryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('In stock'), findsOneWidget);
      expect(find.byTooltip('Sort by'), findsOneWidget);

      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Most used'), findsOneWidget);
      expect(find.text('In stock first'), findsOneWidget);

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();
      expect(find.text('Greek Yogurt'), findsOneWidget);

      await _drainDatabase(tester);
    });

    testWidgets('delete requires confirmation', (tester) async {
      final SharedPreferences prefs = await _prefs();
      final AppDatabase db = AppDatabase.executor(NativeDatabase.memory());
      await _product(db, name: 'Greek Yogurt');

      await tester.pumpWidget(
        _app(db: db, prefs: prefs, home: const ProductsLibraryScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Product'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await db.select(db.products).get(), hasLength(1));

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await db.select(db.products).get(), isEmpty);

      await _drainDatabase(tester);
    });
  });

  group('Recipe library', () {
    testWidgets('rows show portable badge, ingredient preview and macros', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      final AppDatabase db = AppDatabase.executor(NativeDatabase.memory());
      final int oatsId = await _product(db, name: 'Oats');
      final int recipeId = await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              name: 'Oatmeal',
              instructions: 'Mix and heat.',
              isPortable: true,
            ),
          );
      await db
          .into(db.recipeIngredients)
          .insert(
            RecipeIngredientsCompanion.insert(
              recipeId: recipeId,
              productId: oatsId,
              amount: 50,
              amountUnits: const Value('g'),
            ),
          );

      await tester.pumpWidget(
        _app(db: db, prefs: prefs, home: const RecipesLibraryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oatmeal'), findsOneWidget);
      expect(find.text('Portable'), findsOneWidget);
      expect(find.text('Oats (50g)'), findsOneWidget);
      expect(find.textContaining('P 2.5g'), findsOneWidget);

      await _drainDatabase(tester);
    });

    testWidgets('delete requires confirmation', (tester) async {
      final SharedPreferences prefs = await _prefs();
      final AppDatabase db = AppDatabase.executor(NativeDatabase.memory());
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              name: 'Oatmeal',
              instructions: '',
              isPortable: true,
            ),
          );

      await tester.pumpWidget(
        _app(db: db, prefs: prefs, home: const RecipesLibraryScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Recipe'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await db.select(db.recipes).get(), hasLength(1));

      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await db.select(db.recipes).get(), isEmpty);

      await _drainDatabase(tester);
    });
  });

  group('Stock', () {
    test('sorts low stock before healthy rows, most urgent first', () {
      final List<StockWithProduct> sorted =
          sortStocksLowStockFirst(<StockWithProduct>[
            _stock(productId: 1, name: 'Healthy', quantity: 20, trigger: 10),
            _stock(productId: 2, name: 'Almost', quantity: 9, trigger: 10),
            _stock(productId: 3, name: 'Empty', quantity: 1, trigger: 10),
            _stock(productId: 4, name: 'No trigger', quantity: 0),
          ]);

      expect(
        sorted.map((StockWithProduct item) => item.product.name).toList(),
        <String>['Empty', 'Almost', 'Healthy', 'No trigger'],
      );
    });

    testWidgets('changing the display unit does not touch product units', (
      tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      final AppDatabase db = AppDatabase.executor(NativeDatabase.memory());
      final int houseId = await _house(db);
      final int milkId = await _product(
        db,
        name: 'Milk',
        defaultUnits: 'g',
        mlToGFactor: 1,
      );
      await StockRepository(db).saveStock(
        productId: milkId,
        houseId: houseId,
        quantity: 500,
        minTriggerQuantity: 100,
      );

      await tester.pumpWidget(
        _app(db: db, prefs: prefs, home: const StockScreen()),
      );
      await tester.pumpAndSettle();

      final Finder unitPicker = find.byType(DropdownButton<String>).first;
      await tester.tap(unitPicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ml').last);
      await tester.pumpAndSettle();

      final Product product = await (db.select(
        db.products,
      )..where((table) => table.id.equals(milkId))).getSingle();
      expect(product.defaultUnits, 'g');

      final ProductStock stock =
          await (db.select(
                db.productStocks,
              )..where((ProductStocks table) => table.productId.equals(milkId)))
              .getSingle();
      expect(stock.quantity, 500);

      await _drainDatabase(tester);
    });

    testWidgets('receipt row fits a 360dp screen at 1.3 text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final Product matched = Product(
        id: 1,
        name: 'Whole Milk',
        defaultUnits: 'ml',
        edibleQtyPerUnit: 1.0,
        mlToGFactor: 1,
        proteins: 3,
        fats: 3,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
      final ReceiptReviewItem perfect = ReceiptReviewItem(
        receiptName: 'WHOLE MILK 1L',
        inputQuantity: 1,
        parsedUnit: 'l',
        matchedProduct: matched,
        matchState: ReceiptMatchState.perfect,
        isSelected: true,
      );
      final ReceiptReviewItem missing = ReceiptReviewItem(
        receiptName: 'MYSTERY SNACK FAMILY PACK',
        inputQuantity: 2,
        parsedUnit: 'units',
        matchState: ReceiptMatchState.missing,
        isSelected: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: createNexcTheme(lightColorScheme),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: ListView(
                children: <Widget>[
                  ReceiptReviewRow(
                    item: perfect,
                    onToggle: () {},
                    onQuantityChanged: (_) {},
                    onUnitChanged: (_) {},
                    onEdit: () {},
                    onReplace: () {},
                    onCreate: () {},
                  ),
                  ReceiptReviewRow(
                    item: missing,
                    onToggle: () {},
                    onQuantityChanged: (_) {},
                    onUnitChanged: (_) {},
                    onEdit: () {},
                    onReplace: () {},
                    onCreate: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Perfect Match'), findsOneWidget);
      expect(find.text('Not found'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);

      await _drainDatabase(tester);
    });
  });
}
