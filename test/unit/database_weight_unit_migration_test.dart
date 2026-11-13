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
  test('v23 -> v24 converts stored pounds to kilograms', () async {
    final tempDir = Directory.systemTemp.createTempSync('nexc_units_migration');
    final dbFile = File('${tempDir.path}/nexc_database.db');
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    final legacy = sqlite3.open(dbFile.path);
    legacy.execute('''
      CREATE TABLE sets (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        load REAL NOT NULL,
        weightUnit TEXT NOT NULL DEFAULT 'kg'
      );
    ''');
    legacy.execute(
      "INSERT INTO sets (id, load, weightUnit) VALUES (1, 100.0, 'lbs');",
    );
    legacy.execute(
      "INSERT INTO sets (id, load, weightUnit) VALUES (2, 100.0, 'kg');",
    );
    legacy.execute(
      "INSERT INTO sets (id, load, weightUnit) VALUES (3, 0.0, 'lbs');",
    );
    legacy.execute('PRAGMA user_version = 23;');
    legacy.dispose();

    final db = AppDatabase.executor(NativeDatabase(dbFile));
    addTearDown(db.close);

    final converted = await db
        .customSelect("SELECT load, \"weightUnit\" FROM sets WHERE id = 1")
        .getSingle();
    expect(converted.read<double>('load'), closeTo(45.359237, 1e-9));
    expect(converted.read<String>('weightUnit'), 'kg');

    final untouched = await db
        .customSelect("SELECT load, \"weightUnit\" FROM sets WHERE id = 2")
        .getSingle();
    expect(untouched.read<double>('load'), 100.0);
    expect(untouched.read<String>('weightUnit'), 'kg');

    final zero = await db
        .customSelect("SELECT load, \"weightUnit\" FROM sets WHERE id = 3")
        .getSingle();
    expect(zero.read<double>('load'), 0.0);
    expect(zero.read<String>('weightUnit'), 'kg');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 24);

    // Reopening an already migrated database must not divide again.
    await db.close();
    final reopened = AppDatabase.executor(NativeDatabase(dbFile));
    addTearDown(reopened.close);
    final again = await reopened
        .customSelect('SELECT load FROM sets WHERE id = 1')
        .getSingle();
    expect(again.read<double>('load'), closeTo(45.359237, 1e-9));
  });
}
