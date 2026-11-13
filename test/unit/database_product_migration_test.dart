/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test(
    'v21/v22 migrations remove legacy products.weight and repair meals.atHome',
    () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'nexc_migration_test',
      );
      final dbFile = File('${tempDir.path}/nexc_database.db');

      final legacy = sqlite3.open(dbFile.path);
      legacy.execute('''
      CREATE TABLE products (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        weight REAL NOT NULL,
        mlToGFactor INTEGER,
        defaultUnits TEXT,
        edibleQtyPerUnit REAL,
        kcal REAL,
        proteins REAL NOT NULL,
        carbsByDifference REAL,
        carbsAvailable REAL,
        dietaryFiber REAL,
        fats REAL NOT NULL,
        isSupplement BOOLEAN NOT NULL,
        isPortable BOOLEAN NOT NULL DEFAULT 1,
        unitWeight INTEGER,
        isStockRaw BOOLEAN NOT NULL DEFAULT 0
      );
    ''');
      legacy.execute('''
      INSERT INTO products (
        id, name, weight, defaultUnits, edibleQtyPerUnit, proteins, fats,
        isSupplement, isPortable, unitWeight, isStockRaw
      ) VALUES (7, 'Legacy Apple', 182.0, 'unit', 1.0, 0.3, 0.2, 0, 1, 182, 0);
    ''');
      legacy.execute('''
      CREATE TABLE meals (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        mealPlanId INTEGER NOT NULL,
        name TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT NOT NULL,
        position INTEGER NOT NULL
      );
    ''');
      legacy.execute('''
      INSERT INTO meals (mealPlanId, name, time, notes, position)
      VALUES (1, 'Breakfast', '08:00', '', 0);
    ''');
      legacy.execute('PRAGMA user_version = 20;');
      legacy.dispose();

      final db = AppDatabase.executor(NativeDatabase(dbFile));
      addTearDown(() async {
        await db.close();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final columns = await db
          .customSelect('PRAGMA table_info(products)')
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        isNot(contains('weight')),
      );

      final legacyProduct = await (db.select(
        db.products,
      )..where((p) => p.id.equals(7))).getSingle();
      expect(legacyProduct.name, equals('Legacy Apple'));
      expect(legacyProduct.unitWeight, equals(182));

      final insertedId = await db
          .into(db.products)
          .insert(
            ProductsCompanion.insert(
              name: 'New Apple',
              proteins: 0.3,
              fats: 0.2,
              isSupplement: false,
            ),
          );
      expect(insertedId, greaterThan(0));

      final mealColumns = await db
          .customSelect('PRAGMA table_info(meals)')
          .get();
      expect(
        mealColumns.map((row) => row.read<String>('name')),
        contains('atHome'),
      );

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), equals(22));
    },
  );
}
