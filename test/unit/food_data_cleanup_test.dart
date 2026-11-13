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

const _nutrientKeys = <String>[
  'kcal',
  'proteins',
  'carbsByDifference',
  'carbsAvailable',
  'dietaryFiber',
  'fats',
];

const _equivalenceKeys = <String>[
  'defaultUnits',
  'unitWeight',
  'mlToGFactor',
  'edibleQtyPerUnit',
];

final _usdaBoilerplate = RegExp(
  r"includes?\s+foods?\s+for\s+usda'?s?\s+food\s+distribution\s+program",
  caseSensitive: false,
);

final _nonAlphanumeric = RegExp(r'[^a-z0-9]+');
final _multiSpace = RegExp(r'\s+');

String _normalizeName(String name) {
  return name
      .toLowerCase()
      .replaceAll(_nonAlphanumeric, ' ')
      .replaceAll(_multiSpace, ' ')
      .trim();
}

String _signature(Map<String, dynamic> food) {
  return [
    ..._nutrientKeys,
    ..._equivalenceKeys,
  ].map((key) => '${food[key]}').join('|');
}

List<Map<String, dynamic>> _loadFoods() {
  final file = File('assets/foods.json');
  expect(file.existsSync(), isTrue, reason: 'assets/foods.json must exist');
  final decoded = jsonDecode(file.readAsStringSync());
  expect(decoded, isA<List<dynamic>>());
  return (decoded as List<dynamic>)
      .map((entry) => entry as Map<String, dynamic>)
      .toList();
}

void main() {
  group('Food data cleanup invariants', () {
    late List<Map<String, dynamic>> foods;

    setUpAll(() {
      foods = _loadFoods();
    });

    test('contains no USDA boilerplate or redundant apple skin entry', () {
      final boilerplate = foods
          .where((food) => _usdaBoilerplate.hasMatch(food['name'] as String))
          .toList();
      expect(boilerplate, isEmpty);

      final withoutSkinApple = foods.where(
        (food) =>
            (food['name'] as String).trim().toLowerCase() ==
            'apples, raw, without skin',
      );
      expect(withoutSkinApple, isEmpty);

      final canonicalApple = foods.firstWhere((food) => food['id'] == 171688);
      expect(canonicalApple['name'], equals('Apples, raw'));
      expect(canonicalApple['defaultUnits'], equals('unit'));
      expect(canonicalApple['unitWeight'], equals(182));
    });

    test('has no exact duplicate names', () {
      final seen = <String, int>{};
      final duplicates = <String>[];
      for (final food in foods) {
        final name = (food['name'] as String).trim().toLowerCase();
        if (seen.containsKey(name)) {
          duplicates.add('$name (ids ${seen[name]}, ${food['id']})');
        } else {
          seen[name] = food['id'] as int;
        }
      }
      expect(duplicates, isEmpty);
    });

    test('normalized duplicate names carry distinct nutrition payloads', () {
      final groups = <String, List<Map<String, dynamic>>>{};
      for (final food in foods) {
        groups
            .putIfAbsent(_normalizeName(food['name'] as String), () => [])
            .add(food);
      }

      for (final entry in groups.entries) {
        if (entry.value.length < 2) continue;
        final signatures = entry.value.map(_signature).toSet();
        expect(
          signatures.length,
          entry.value.length,
          reason:
              'Normalized name "${entry.key}" is shared by entries with an '
              'identical nutrition payload (ids '
              '${entry.value.map((food) => food['id']).join(', ')}). '
              'Run scripts/clean_food_data.py --check.',
        );
      }
    });

    test('unit and ml entries have complete measurement equivalences', () {
      final gaps = <String>[];
      for (final food in foods) {
        final id = food['id'];
        final name = food['name'];
        switch (food['defaultUnits']) {
          case 'unit':
            final unitWeight = food['unitWeight'];
            if (unitWeight is! num || unitWeight <= 0) {
              gaps.add('id $id: unit without positive unitWeight ($name)');
            }
            break;
          case 'ml':
            final factor = food['mlToGFactor'];
            if (factor is! num || factor <= 0) {
              gaps.add('id $id: ml without positive mlToGFactor ($name)');
            }
            break;
          case 'g':
            break;
          default:
            gaps.add(
              'id $id: unsupported defaultUnits ${food['defaultUnits']} ($name)',
            );
        }
      }
      expect(gaps, isEmpty, reason: gaps.join('\n'));
    });
  });
}
