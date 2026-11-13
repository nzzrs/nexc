/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import '../backup_manager.dart';
import '../../db/app_database.dart';

Future<void> exportRawDatabase(AppDatabase db) async {
  throw UnsupportedError('Raw database file export is not supported on this platform. Use JSON backup.');
}

Future<ImportResult> importRawDatabase(AppDatabase db) async {
  return const ImportResult.fail('Raw database file import is not supported on this platform. Use JSON backup.');
}
