/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:string_similarity/string_similarity.dart';
import '../db/app_database.dart' show Product;

class ScoredProduct {
  final Product product;
  final double score;

  const ScoredProduct(this.product, this.score);

  @override
  String toString() => 'ScoredProduct(product: ${product.name}, score: $score)';
}

class ParsedPortion {
  final double amount;
  final String unit;

  const ParsedPortion({required this.amount, required this.unit});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedPortion &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          unit == other.unit;

  @override
  int get hashCode => Object.hash(amount, unit);

  @override
  String toString() => 'ParsedPortion(amount: $amount, unit: $unit)';
}

class FuzzyFoodMatcher {
  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Matches and ranks [products] based on fuzzy token matching, typo tolerance,
  /// token order invariance, usage counts, and in-stock status.
  static List<ScoredProduct> matchProducts(
    String query,
    List<Product> products, {
    Map<int, int>? usageCounts,
    Set<int>? inStockIds,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      final list = products.map((p) {
        double score = 0.0;
        if (inStockIds != null && inStockIds.contains(p.id)) {
          score += 100.0;
        }
        if (usageCounts != null && usageCounts.containsKey(p.id)) {
          score += usageCounts[p.id]! * 2.0;
        }
        return ScoredProduct(p, score);
      }).toList();
      list.sort((a, b) => b.score.compareTo(a.score));
      return list;
    }

    final queryTokens = _tokenize(cleanQuery);

    final scored = products.map((product) {
      final nameLower = product.name.toLowerCase();
      final productTokens = _tokenize(nameLower);

      double score = 0.0;

      // Exact phrase match
      if (nameLower == cleanQuery) {
        score += 100.0;
      } else if (nameLower.startsWith(cleanQuery)) {
        score += 50.0;
      } else if (nameLower.contains(cleanQuery)) {
        score += 30.0;
      }

      // Token order invariant matching: check how many query tokens match product tokens
      int matchedTokens = 0;
      for (final qToken in queryTokens) {
        if (productTokens.contains(qToken)) {
          matchedTokens++;
          score += 15.0;
        } else {
          // Token-level typo tolerance
          double maxSim = 0.0;
          for (final pToken in productTokens) {
            final sim = StringSimilarity.compareTwoStrings(qToken, pToken);
            if (sim > maxSim) maxSim = sim;
          }
          if (maxSim >= 0.75) {
            matchedTokens++;
            score += 10.0 * maxSim;
          }
        }
      }

      // If all query tokens matched, give a big boost
      if (queryTokens.isNotEmpty && matchedTokens == queryTokens.length) {
        score += 40.0;
      }

      // Full string similarity typo tolerance
      final stringSim = StringSimilarity.compareTwoStrings(cleanQuery, nameLower);
      score += stringSim * 25.0;

      // Penalize slight length disparity
      score -= (product.name.length - cleanQuery.length).abs() * 0.05;

      // Penalize redundant USDA overly-specific duplicates if a simpler canonical exists
      // e.g. "without skin", "with skin (Includes foods for USDA's Food Distribution Program)"
      final isRedundantVariant = nameLower.contains('without skin') ||
          nameLower.contains('(includes foods for usda') ||
          nameLower.contains('unheated') ||
          nameLower.contains('without added ascorbic acid');
      if (isRedundantVariant) {
        score -= 25.0;
      }

      // In-stock boost
      if (inStockIds != null && inStockIds.contains(product.id)) {
        score += 12.0;
      }

      // Usage boost
      if (usageCounts != null && usageCounts.containsKey(product.id)) {
        score += usageCounts[product.id]! * 2.5;
      }

      return ScoredProduct(product, score);
    }).toList();

    // Filter out irrelevant products: must have some positive score or token match
    final filtered = scored.where((sp) => sp.score > 5.0).toList();
    filtered.sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }
}

class PortionConverter {
  static final RegExp _fractionPattern = RegExp(r'^(?:(\d+)\s+)?(\d+)\s*/\s*(\d+)\s*(.*)$');
  static final RegExp _decimalPattern = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$');

  /// Parses imprecise portion strings like "500g", "1.5 kg", "2 cups", "1/2 cup", "12 oz".
  static ParsedPortion parsePortionString(String input) {
    final clean = input.trim();
    if (clean.isEmpty) {
      return const ParsedPortion(amount: 0.0, unit: '');
    }

    // Try fraction: "1/2 cup", "1 1/2 cups"
    final fracMatch = _fractionPattern.firstMatch(clean);
    if (fracMatch != null) {
      final wholeStr = fracMatch.group(1);
      final numStr = fracMatch.group(2)!;
      final denStr = fracMatch.group(3)!;
      final unitStr = fracMatch.group(4)!.trim();

      final whole = wholeStr != null ? double.parse(wholeStr) : 0.0;
      final num = double.parse(numStr);
      final den = double.parse(denStr);
      final amount = den != 0.0 ? whole + (num / den) : 0.0;
      return ParsedPortion(amount: amount, unit: _normalizeUnit(unitStr));
    }

    // Decimal or integer: "500g", "1.5 kg", "12 oz"
    final decMatch = _decimalPattern.firstMatch(clean);
    if (decMatch != null) {
      final amountStr = decMatch.group(1)!;
      final unitStr = decMatch.group(2)!.trim();
      final amount = double.parse(amountStr);
      return ParsedPortion(amount: amount, unit: _normalizeUnit(unitStr));
    }

    return ParsedPortion(amount: 0.0, unit: _normalizeUnit(clean));
  }

  static String _normalizeUnit(String raw) {
    final u = raw.toLowerCase().trim();
    if (u == 'g' || u == 'gram' || u == 'grams') return 'g';
    if (u == 'kg' || u == 'kilogram' || u == 'kilograms') return 'kg';
    if (u == 'oz' || u == 'ounce' || u == 'ounces') return 'oz';
    if (u == 'lb' || u == 'lbs' || u == 'pound' || u == 'pounds') return 'lb';
    if (u == 'ml' || u == 'milliliter' || u == 'milliliters') return 'ml';
    if (u == 'l' || u == 'liter' || u == 'liters') return 'l';
    if (u == 'cup' || u == 'cups') return 'cup';
    if (u == 'tbsp' || u == 'tablespoon' || u == 'tablespoons') return 'tbsp';
    if (u == 'tsp' || u == 'teaspoon' || u == 'teaspoons') return 'tsp';
    if (u == 'scoop' || u == 'scoops') return 'scoop';
    if (u == 'pinch' || u == 'pinches') return 'pinch';
    if (u == 'glass' || u == 'glasses') return 'glass';
    if (u == 'slice' || u == 'slices') return 'slice';
    if (u == 'can' || u == 'cans') return 'can';
    if (u == 'unit' || u == 'units' || u == 'piece' || u == 'pieces' || u == 'serving' || u == 'servings') {
      return 'unit';
    }
    return u;
  }

  /// Converts [amount] from [sourceUnit] to [targetUnit] for a given [product],
  /// taking into account density ([Product.mlToGFactor]) and [Product.unitWeight].
  static double convertPortion(
    double amount,
    String sourceUnit,
    String targetUnit,
    Product product,
  ) {
    final src = _normalizeUnit(sourceUnit);
    final dst = _normalizeUnit(targetUnit);

    if (src == dst) return amount;

    // Density factor (grams per ml)
    final double density = (product.mlToGFactor != null && product.mlToGFactor! > 0)
        ? product.mlToGFactor!.toDouble()
        : 1.0;

    // Unit weight (grams per unit)
    final double unitWeight = (product.unitWeight != null && product.unitWeight! > 0)
        ? product.unitWeight!.toDouble()
        : 100.0;

    // 1. Convert source to grams
    double grams = 0.0;
    switch (src) {
      case 'g':
        grams = amount;
        break;
      case 'kg':
        grams = amount * 1000.0;
        break;
      case 'oz':
        grams = amount * 28.349523125;
        break;
      case 'lb':
        grams = amount * 453.59237;
        break;
      case 'ml':
        grams = amount * density;
        break;
      case 'l':
        grams = amount * 1000.0 * density;
        break;
      case 'cup':
        grams = amount * 240.0 * density;
        break;
      case 'tbsp':
        grams = amount * 15.0 * density;
        break;
      case 'tsp':
        grams = amount * 5.0 * density;
        break;
      case 'scoop':
        grams = amount * (product.isSupplement ? 30.0 : 45.0);
        break;
      case 'pinch':
        grams = amount * 0.36;
        break;
      case 'glass':
        grams = amount * 250.0 * density;
        break;
      case 'slice':
        grams = amount * 30.0;
        break;
      case 'can':
        grams = amount * 330.0 * density;
        break;
      case 'unit':
        grams = amount * unitWeight;
        break;
      default:
        grams = amount;
    }

    // 2. Convert grams to destination
    switch (dst) {
      case 'g':
        return grams;
      case 'kg':
        return grams / 1000.0;
      case 'oz':
        return grams / 28.349523125;
      case 'lb':
        return grams / 453.59237;
      case 'ml':
        return density > 0 ? grams / density : grams;
      case 'l':
        return density > 0 ? (grams / density) / 1000.0 : grams / 1000.0;
      case 'cup':
        return density > 0 ? (grams / density) / 240.0 : grams / 240.0;
      case 'tbsp':
        return density > 0 ? (grams / density) / 15.0 : grams / 15.0;
      case 'tsp':
        return density > 0 ? (grams / density) / 5.0 : grams / 5.0;
      case 'scoop':
        final scoopGrams = product.isSupplement ? 30.0 : 45.0;
        return grams / scoopGrams;
      case 'pinch':
        return grams / 0.36;
      case 'glass':
        return density > 0 ? (grams / density) / 250.0 : grams / 250.0;
      case 'slice':
        return grams / 30.0;
      case 'can':
        return density > 0 ? (grams / density) / 330.0 : grams / 330.0;
      case 'unit':
        return unitWeight > 0 ? grams / unitWeight : grams;
      default:
        return grams;
    }
  }
}

// Top-level contract aliases
List<ScoredProduct> matchProducts(
  String query,
  List<Product> products, {
  Map<int, int>? usageCounts,
  Set<int>? inStockIds,
}) =>
    FuzzyFoodMatcher.matchProducts(query, products,
        usageCounts: usageCounts, inStockIds: inStockIds);

ParsedPortion parsePortionString(String input) =>
    PortionConverter.parsePortionString(input);

double convertPortion(
  double amount,
  String sourceUnit,
  String targetUnit,
  Product product,
) =>
    PortionConverter.convertPortion(amount, sourceUnit, targetUnit, product);
