/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import '../providers/db_provider.dart';

class StockWithProduct {
  final ProductStock stock;
  final Product product;

  StockWithProduct({
    required this.stock,
    required this.product,
  });
}

class StockRepository {
  final AppDatabase db;

  StockRepository(this.db);

  // Houses CRUD
  Stream<List<House>> watchHouses() {
    return (db.select(db.houses)..orderBy([(h) => OrderingTerm(expression: h.name)])).watch();
  }

  Future<List<House>> getHouses() {
    return (db.select(db.houses)..orderBy([(h) => OrderingTerm(expression: h.name)])).get();
  }

  Future<int> saveHouse(House house) async {
    if (house.id == 0) {
      return db.into(db.houses).insert(
            HousesCompanion.insert(
              name: house.name,
            ),
          );
    } else {
      await db.update(db.houses).replace(house);
      return house.id;
    }
  }

  Future<void> deleteHouse(House house) {
    return db.delete(db.houses).delete(house);
  }

  // Stock CRUD
  Stream<List<StockWithProduct>> watchStocksWithProductForHouse(int houseId) {
    final query = db.select(db.productStocks).join([
      innerJoin(db.products, db.products.id.equalsExp(db.productStocks.productId)),
    ])
      ..where(db.productStocks.houseId.equals(houseId))
      ..orderBy([OrderingTerm(expression: db.products.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return StockWithProduct(
          stock: row.readTable(db.productStocks),
          product: row.readTable(db.products),
        );
      }).toList();
    });
  }

  Future<List<StockWithProduct>> getStocksWithProductForHouse(int houseId) async {
    final query = db.select(db.productStocks).join([
      innerJoin(db.products, db.products.id.equalsExp(db.productStocks.productId)),
    ])
      ..where(db.productStocks.houseId.equals(houseId))
      ..orderBy([OrderingTerm(expression: db.products.name)]);

    final rows = await query.get();
    return rows.map((row) {
      return StockWithProduct(
        stock: row.readTable(db.productStocks),
        product: row.readTable(db.products),
      );
    }).toList();
  }

  Future<int> saveStock({
    required int productId,
    required int houseId,
    required double quantity,
    required double? minTriggerQuantity,
    String? inputUnit,
  }) async {
    final product = await (db.select(db.products)..where((p) => p.id.equals(productId))).getSingleOrNull();
    if (product == null) {
      throw Exception("Product not found");
    }

    final double roundedQty = double.parse(quantity.toStringAsFixed(2));
    final double? roundedTrigger = minTriggerQuantity == null ? null : double.parse(minTriggerQuantity.toStringAsFixed(2));

    final unit = (inputUnit ?? product.defaultUnits ?? 'g').toLowerCase().trim();
    final double unitW = (product.unitWeight != null && product.unitWeight! > 0)
        ? product.unitWeight!.toDouble()
        : 0.0;
    final double mlToG = (product.mlToGFactor != null && product.mlToGFactor! > 0)
        ? product.mlToGFactor!.toDouble()
        : 0.0;

    double grams = 0.0;
    double ml = 0.0;
    double units = 0.0;

    if (unit == 'units' || unit == 'unit') {
      units = roundedQty;
      grams = units * unitW;
      ml = mlToG > 0 ? grams / mlToG : 0.0;
    } else if (unit == 'ml') {
      ml = roundedQty;
      grams = mlToG > 0 ? ml * mlToG : 0.0;
      units = unitW > 0 ? grams / unitW : 0.0;
    } else {
      grams = roundedQty;
      ml = mlToG > 0 ? grams / mlToG : 0.0;
      units = unitW > 0 ? grams / unitW : 0.0;
    }

    final double finalGrams = double.parse(grams.toStringAsFixed(2));
    final double finalMl = double.parse(ml.toStringAsFixed(2));
    final double finalUnits = double.parse(units.toStringAsFixed(2));

    final companion = ProductStocksCompanion.insert(
      productId: productId,
      houseId: houseId,
      quantity: roundedQty,
      minTriggerQuantity: Value(roundedTrigger),
      quantityGrams: Value(finalGrams),
      quantityMl: Value(finalMl),
      quantityUnits: Value(finalUnits),
    );

    return db.into(db.productStocks).insert(
          companion,
          onConflict: DoUpdate(
            (old) => ProductStocksCompanion(
              quantity: Value(roundedQty),
              minTriggerQuantity: Value(roundedTrigger),
              quantityGrams: Value(finalGrams),
              quantityMl: Value(finalMl),
              quantityUnits: Value(finalUnits),
            ),
            target: [db.productStocks.productId, db.productStocks.houseId],
          ),
        );
  }

  Future<void> deleteStock(ProductStock stock) {
    return db.delete(db.productStocks).delete(stock);
  }

  // Receipt Mappings
  Future<List<ReceiptMapping>> getReceiptMappings() {
    return db.select(db.receiptMappings).get();
  }

  Future<ReceiptMapping?> getMappingForReceiptName(String receiptName) {
    final query = db.select(db.receiptMappings)
      ..where((t) => t.receiptName.equals(receiptName.toLowerCase().trim()));
    return query.getSingleOrNull();
  }

  Future<void> saveReceiptMapping({required String receiptName, required int productId}) async {
    final cleaned = receiptName.toLowerCase().trim();
    final companion = ReceiptMappingsCompanion.insert(
      receiptName: cleaned,
      productId: productId,
    );
    await db.into(db.receiptMappings).insert(
          companion,
          onConflict: DoUpdate(
            (old) => ReceiptMappingsCompanion(
              productId: Value(productId),
            ),
            target: [db.receiptMappings.receiptName],
          ),
        );
  }

  // Ensure default house exists
  Future<void> ensureDefaultHouse() async {
    final houses = await getHouses();
    if (houses.isEmpty) {
      await saveHouse(const House(id: 0, name: "My House"));
    }
  }
}

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final db = ref.watch(dbProvider);
  return StockRepository(db);
});
