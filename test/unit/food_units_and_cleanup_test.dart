/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/db/enums.dart';

void main() {
  group('Food Data Cleanup & Unit Restrictions Tests', () {
    test('foods.json contains no redundant apple skin entries and no USDA boilerplate', () {
      final file = File('assets/foods.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> foods = jsonDecode(file.readAsStringSync());

      // 1. Verify no "Apples, raw, without skin"
      final withoutSkinApples = foods.where((f) => (f['name'] as String).toLowerCase() == 'apples, raw, without skin').toList();
      expect(withoutSkinApples, isEmpty);

      // 2. Verify canonical "Apples, raw" is present and configured with unit
      final canonicalApple = foods.firstWhere((f) => f['id'] == 171688);
      expect(canonicalApple['name'], equals('Apples, raw'));
      expect(canonicalApple['defaultUnits'], equals('unit'));
      expect(canonicalApple['unitWeight'], equals(182));

      // 3. Verify no "(Includes foods for USDA's Food Distribution Program)"
      final usdaProgramEntries = foods.where((f) => (f['name'] as String).contains("Food Distribution Program")).toList();
      expect(usdaProgramEntries, isEmpty);
    });

    test('Product unit restriction extensions properly constrain available units', () {
      // 1. Pure solid powder / grain (e.g. Chicken breast, Rice)
      const pSolid = Product(
        id: 1,
        name: 'Chicken Breast',
        defaultUnits: 'g',
        edibleQtyPerUnit: 1.0,
        proteins: 31.0,
        fats: 3.6,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
      expect(pSolid.canMeasureInMl, isFalse);
      expect(pSolid.canMeasureInUnits, isFalse);
      expect(pSolid.availableAmountUnits, equals([AmountUnit.GRAMS]));
      expect(pSolid.availableStringUnits, equals(['g', 'kg']));

      // 2. Liquid product (e.g. Whole Milk)
      const pLiquid = Product(
        id: 2,
        name: 'Whole Milk',
        defaultUnits: 'ml',
        mlToGFactor: 1,
        edibleQtyPerUnit: 1.0,
        proteins: 3.3,
        fats: 3.6,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
      expect(pLiquid.canMeasureInMl, isTrue);
      expect(pLiquid.canMeasureInUnits, isFalse);
      expect(pLiquid.availableAmountUnits, equals([AmountUnit.GRAMS, AmountUnit.ML]));
      expect(pLiquid.availableStringUnits, equals(['g', 'kg', 'ml', 'l']));

      // 3. Discrete food (e.g. Apple, Banana, Egg)
      const pDiscrete = Product(
        id: 3,
        name: 'Apples, raw',
        defaultUnits: 'unit',
        unitWeight: 182,
        edibleQtyPerUnit: 1.0,
        proteins: 0.26,
        fats: 0.17,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
      expect(pDiscrete.canMeasureInMl, isFalse);
      expect(pDiscrete.canMeasureInUnits, isTrue);
      expect(pDiscrete.availableAmountUnits, equals([AmountUnit.GRAMS, AmountUnit.UNITS]));
      expect(pDiscrete.availableStringUnits, equals(['g', 'kg', 'units']));

      // 4. Product with both ml and unit weight (e.g. canned beverage with bottle weight)
      const pBoth = Product(
        id: 4,
        name: 'Canned Soda',
        defaultUnits: 'ml',
        mlToGFactor: 1,
        unitWeight: 355,
        edibleQtyPerUnit: 1.0,
        proteins: 0.0,
        fats: 0.0,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
      expect(pBoth.canMeasureInMl, isTrue);
      expect(pBoth.canMeasureInUnits, isTrue);
      expect(pBoth.availableAmountUnits, equals([AmountUnit.GRAMS, AmountUnit.ML, AmountUnit.UNITS]));
      expect(pBoth.availableStringUnits, equals(['g', 'kg', 'ml', 'l', 'units']));
    });
  });
}
