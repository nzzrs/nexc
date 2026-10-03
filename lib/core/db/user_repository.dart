/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:drift/drift.dart';
import 'app_database.dart';

class UserRepository {
  final AppDatabase db;
  UserRepository(this.db);

  Future<UserData?> getUser() async {
    final users = await db.select(db.users).get();
    return users.isEmpty ? null : users.first;
  }

  Stream<UserData?> watchUser() {
    return db.select(db.users).watchSingleOrNull();
  }

  Future<void> saveUser({DateTime? birthDate, double? height}) async {
    final existing = await getUser();
    if (existing == null) {
      await db.into(db.users).insert(
        UsersCompanion.insert(
          birthDate: Value(birthDate),
          height: Value(height),
        ),
      );
    } else {
      await (db.update(db.users)..where((t) => t.id.equals(existing.id))).write(
        UsersCompanion(
          birthDate: Value(birthDate),
          height: Value(height),
        ),
      );
    }
  }
}
