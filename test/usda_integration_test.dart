import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/db/dataset_repository.dart';
import 'package:nexc_flutter/core/providers/db_provider.dart';
import 'package:nexc_flutter/core/providers/settings_provider.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('USDA foods integration test', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase.executor(NativeDatabase.memory());

    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    // Trigger updateDatasetOnAppUpdate
    await container.read(datasetRepositoryProvider).updateDatasetOnAppUpdate(1);

    // Verify products count is 7802 (7793 USDA products + 9 default products)
    final productsCountExpr = db.products.id.count();
    final productsCountQuery = db.selectOnly(db.products)..addColumns([productsCountExpr]);
    final productsCountResult = await productsCountQuery.getSingle();
    final productsCount = productsCountResult.read(productsCountExpr) ?? 0;

    expect(productsCount, equals(7802));

    // Verify a sample USDA product is present
    final sample = await (db.select(db.products)..where((tbl) => tbl.id.equals(167512))).getSingle();
    expect(sample.name, equals("Pillsbury Golden Layer Buttermilk Biscuits, Artificial Flavor, refrigerated dough"));
    expect(sample.kcal, equals(307.0));
    expect(sample.proteins, equals(5.88));
    expect(sample.fats, equals(13.2));
    expect(sample.defaultUnits, equals("g"));
    expect(sample.isSupplement, isFalse);

    // Fetch all products to test relevance search
    final allProducts = await db.select(db.products).get();

    // 1. Test "banana" search
    final bananaResults = allProducts.searchAndSort("banana");
    expect(bananaResults.isNotEmpty, isTrue);
    // "Banana" (default) and "Bananas, raw" should be at the absolute top
    expect(bananaResults[0].name, equals("Banana"));
    expect(bananaResults[1].name, equals("Bananas, raw"));

    // 2. Test "apple" search
    final appleResults = allProducts.searchAndSort("apple");
    expect(appleResults.isNotEmpty, isTrue);
    // "Apples, raw, with skin ..." and without skin should be at the top, not baby food.
    expect(appleResults[0].name.toLowerCase().startsWith("apples, raw"), isTrue);
    expect(appleResults[1].name.toLowerCase().startsWith("apples, raw"), isTrue);

    // 3. Test "oatmeal" search mapping to "oats"
    final oatmealResults = allProducts.searchAndSort("oatmeal");
    expect(oatmealResults.isNotEmpty, isTrue);
    // Generic unenriched oats / oatmeal / oat bran should be at the top
    expect(oatmealResults.first.name.toLowerCase(), contains("oat"));
    expect(oatmealResults.first.name.contains("Babyfood"), isFalse);

    await db.close();
  });
}
