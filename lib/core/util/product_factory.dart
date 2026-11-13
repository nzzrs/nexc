/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import '../db/app_database.dart';

/// Creates an unsaved product pre-filled with safe defaults.
///
/// Search results, the library, the stock screen and the AI receipt flow all
/// open the product editor with this template so the defaults never diverge.
Product emptyProduct({String name = '', String defaultUnits = 'g'}) {
  return Product(
    id: 0,
    name: name,
    defaultUnits: defaultUnits,
    edibleQtyPerUnit: 1.0,
    kcal: 0.0,
    proteins: 0.0,
    carbsAvailable: null,
    fats: 0.0,
    isSupplement: false,
    isPortable: true,
    isStockRaw: false,
  );
}

/// Picks the default unit for a product created from a receipt line.
String defaultUnitsForReceiptUnit(String parsedUnit) {
  switch (parsedUnit.trim().toLowerCase()) {
    case 'l':
    case 'ml':
    case 'lt':
    case 'liter':
    case 'litre':
      return 'ml';
    case 'unit':
    case 'units':
    case 'u':
      return 'units';
    default:
      return 'g';
  }
}
