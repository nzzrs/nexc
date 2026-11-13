/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nexc_database'));

    // On Android, if the Room database already exists, we must use it.
    if (Platform.isAndroid) {
      final androidDbFile = File('/data/data/org.nexc/databases/nexc_database');
      if (await androidDbFile.exists()) {
        return NativeDatabase(androidDbFile);
      }
    }

    return NativeDatabase(file);
  });
}
