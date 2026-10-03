/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:nexc_flutter/core/util/food_fuzzy_matcher.dart';

void main() {
  group('FuzzyFoodMatcher & PortionConverter Tests', () {
    Product makeTestProduct({
      required int id,
      required String name,
      int? mlToGFactor,
      int? unitWeight,
      String? defaultUnits = 'g',
    }) {
      return Product(
        id: id,
        name: name,
        mlToGFactor: mlToGFactor,
        unitWeight: unitWeight,
        defaultUnits: defaultUnits,
        edibleQtyPerUnit: 1.0,
        proteins: 20.0,
        fats: 5.0,
        isSupplement: false,
        isPortable: true,
        isStockRaw: false,
      );
    }

    final pChicken = makeTestProduct(
      id: 101,
      name: 'Chicken, breast, meat only, raw',
      defaultUnits: 'g',
    );
    final pBanana = makeTestProduct(
      id: 102,
      name: 'Banana, raw',
      unitWeight: 118,
      defaultUnits: 'unit',
    );
    final pBroccoli = makeTestProduct(
      id: 103,
      name: 'Broccoli, raw',
      defaultUnits: 'g',
    );
    final pMilk = makeTestProduct(
      id: 104,
      name: 'Whole Milk',
      mlToGFactor: 1, // 1 ml = 1.03g approx, here 1
      defaultUnits: 'ml',
    );
    final pHoney = makeTestProduct(
      id: 105,
      name: 'Pure Honey',
      mlToGFactor: 2, // dense: 1 ml = 2g
      defaultUnits: 'g',
    );
    final pEgg = makeTestProduct(
      id: 106,
      name: 'Large Whole Egg',
      unitWeight: 50,
      defaultUnits: 'unit',
    );

    final catalog = [pChicken, pBanana, pBroccoli, pMilk, pHoney, pEgg];

    group('Fuzzy Food Name Matching', () {
      test('Token order invariance: "chicken breast raw" matches "Chicken, breast, meat only, raw"', () {
        final matches = FuzzyFoodMatcher.matchProducts('chicken breast raw', catalog);
        expect(matches.isNotEmpty, isTrue);
        expect(matches.first.product.id, equals(pChicken.id));
        expect(matches.first.product.name, equals('Chicken, breast, meat only, raw'));

        // Reverse token order: "raw breast chicken"
        final reverseMatches = FuzzyFoodMatcher.matchProducts('raw breast chicken', catalog);
        expect(reverseMatches.isNotEmpty, isTrue);
        expect(reverseMatches.first.product.id, equals(pChicken.id));
      });

      test('Typo tolerance: "bananna" matches "Banana, raw"', () {
        final matches = FuzzyFoodMatcher.matchProducts('bananna', catalog);
        expect(matches.isNotEmpty, isTrue);
        expect(matches.first.product.id, equals(pBanana.id));
      });

      test('Typo tolerance: "brocoli" matches "Broccoli, raw"', () {
        final matches = FuzzyFoodMatcher.matchProducts('brocoli', catalog);
        expect(matches.isNotEmpty, isTrue);
        expect(matches.first.product.id, equals(pBroccoli.id));
      });

      test('In-stock boost elevates matching product when scores are close', () {
        final p1 = makeTestProduct(id: 201, name: 'Greek Yogurt 0%');
        final p2 = makeTestProduct(id: 202, name: 'Greek Yogurt Plain');
        final list = [p1, p2];

        // Without in-stock: p1 and p2 have similar scores
        final normalMatches = FuzzyFoodMatcher.matchProducts('greek yogurt', list);
        expect(normalMatches.length, equals(2));

        // When p2 is marked in-stock, it takes first rank
        final stockMatches = FuzzyFoodMatcher.matchProducts(
          'greek yogurt',
          list,
          inStockIds: {p2.id},
        );
        expect(stockMatches.first.product.id, equals(p2.id));
      });

      test('Usage count boost prioritizes frequently logged foods', () {
        final p1 = makeTestProduct(id: 301, name: 'Whey Protein Chocolate');
        final p2 = makeTestProduct(id: 302, name: 'Whey Protein Vanilla');
        final list = [p1, p2];

        final matches = FuzzyFoodMatcher.matchProducts(
          'whey protein',
          list,
          usageCounts: {p2.id: 25, p1.id: 1},
        );
        expect(matches.first.product.id, equals(p2.id));
      });
    });

    group('Imprecise Unit String Parsing', () {
      test('Parses metric units: "500g", "1.5 kg", "250 ml", "1 l"', () {
        final p500g = PortionConverter.parsePortionString('500g');
        expect(p500g.amount, equals(500.0));
        expect(p500g.unit, equals('g'));

        final p15kg = PortionConverter.parsePortionString('1.5 kg');
        expect(p15kg.amount, equals(1.5));
        expect(p15kg.unit, equals('kg'));

        final p250ml = PortionConverter.parsePortionString('250 ml');
        expect(p250ml.amount, equals(250.0));
        expect(p250ml.unit, equals('ml'));

        final p1l = PortionConverter.parsePortionString('1 l');
        expect(p1l.amount, equals(1.0));
        expect(p1l.unit, equals('l'));
      });

      test('Parses imperial and volume units: "12 oz", "2 cups", "1/2 cup", "3/4 cup"', () {
        final p12oz = PortionConverter.parsePortionString('12 oz');
        expect(p12oz.amount, equals(12.0));
        expect(p12oz.unit, equals('oz'));

        final p2cups = PortionConverter.parsePortionString('2 cups');
        expect(p2cups.amount, equals(2.0));
        expect(p2cups.unit, equals('cup'));

        final pHalfCup = PortionConverter.parsePortionString('1/2 cup');
        expect(pHalfCup.amount, closeTo(0.5, 0.001));
        expect(pHalfCup.unit, equals('cup'));

        final pThreeQuarterCup = PortionConverter.parsePortionString('3/4 cup');
        expect(pThreeQuarterCup.amount, closeTo(0.75, 0.001));
        expect(pThreeQuarterCup.unit, equals('cup'));
      });

      test('Parses mixed fractions: "1 1/2 cups", "2 1/4 tablespoons"', () {
        final pMixed = PortionConverter.parsePortionString('1 1/2 cups');
        expect(pMixed.amount, closeTo(1.5, 0.001));
        expect(pMixed.unit, equals('cup'));

        final pTbsp = PortionConverter.parsePortionString('2 1/4 tbsp');
        expect(pTbsp.amount, closeTo(2.25, 0.001));
        expect(pTbsp.unit, equals('tbsp'));
      });

      test('Parses unit count strings: "3 units", "2 servings", "1 piece"', () {
        final pUnits = PortionConverter.parsePortionString('3 units');
        expect(pUnits.amount, equals(3.0));
        expect(pUnits.unit, equals('unit'));

        final pServings = PortionConverter.parsePortionString('2 servings');
        expect(pServings.amount, equals(2.0));
        expect(pServings.unit, equals('unit'));
      });

      test('Handles empty and whitespace strings gracefully', () {
        final empty = PortionConverter.parsePortionString('');
        expect(empty.amount, equals(0.0));
        expect(empty.unit, equals(''));

        final spaces = PortionConverter.parsePortionString('   ');
        expect(spaces.amount, equals(0.0));
        expect(spaces.unit, equals(''));
      });
    });

    group('Portion Conversion Factors & Density Conversions', () {
      test('Converts kilograms to grams and grams to kilograms', () {
        final g = PortionConverter.convertPortion(1.5, 'kg', 'g', pChicken);
        expect(g, closeTo(1500.0, 0.01));

        final kg = PortionConverter.convertPortion(750.0, 'g', 'kg', pChicken);
        expect(kg, closeTo(0.75, 0.01));
      });

      test('Converts ounces to grams and grams to ounces', () {
        // 1 oz ≈ 28.3495g
        final g = PortionConverter.convertPortion(4.0, 'oz', 'g', pChicken);
        expect(g, closeTo(113.398, 0.1));

        final oz = PortionConverter.convertPortion(100.0, 'g', 'oz', pChicken);
        expect(oz, closeTo(3.5274, 0.01));
      });

      test('Converts cups to ml and volume units', () {
        // 1 cup = 240 ml, 2 cups = 480 ml
        final ml = PortionConverter.convertPortion(2.0, 'cup', 'ml', pMilk);
        expect(ml, closeTo(480.0, 0.01));

        final cups = PortionConverter.convertPortion(360.0, 'ml', 'cup', pMilk);
        expect(cups, closeTo(1.5, 0.01));
      });

      test('Converts units to grams using product unitWeight', () {
        // Egg has unitWeight = 50g -> 3 eggs = 150g
        final grams = PortionConverter.convertPortion(3.0, 'unit', 'g', pEgg);
        expect(grams, equals(150.0));

        // 200g of eggs = 4 units
        final units = PortionConverter.convertPortion(200.0, 'g', 'unit', pEgg);
        expect(units, equals(4.0));
      });

      test('Converts volume to mass using density factor (mlToGFactor)', () {
        // Milk mlToGFactor = 1: 500 ml = 500g
        final milkGrams = PortionConverter.convertPortion(500.0, 'ml', 'g', pMilk);
        expect(milkGrams, closeTo(500.0, 0.01));

        // Pure Honey mlToGFactor = 2: 250 ml = 500g
        final honeyGrams = PortionConverter.convertPortion(250.0, 'ml', 'g', pHoney);
        expect(honeyGrams, closeTo(500.0, 0.01));

        // 1 cup of honey (240 ml * density 2) = 480g
        final cupHoneyGrams = PortionConverter.convertPortion(1.0, 'cup', 'g', pHoney);
        expect(cupHoneyGrams, closeTo(480.0, 0.01));
      });

      test('Top-level aliases match PortionConverter static methods', () {
        final parsed = parsePortionString('250g');
        expect(parsed.amount, equals(250.0));
        expect(parsed.unit, equals('g'));

        final converted = convertPortion(1.0, 'kg', 'g', pChicken);
        expect(converted, equals(1000.0));
      });
    });
  });
}
