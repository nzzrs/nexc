/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../backup_manager.dart';
import '../../db/app_database.dart';

Future<void> exportRawDatabase(AppDatabase db) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dbFolder.path, 'nexc_database'));
  if (await dbFile.exists()) {
    final tempDir = await getTemporaryDirectory();
    final backupFile = File(p.join(tempDir.path, 'nexc_database_backup.db'));
    await dbFile.copy(backupFile.path);
    await Share.shareXFiles([XFile(backupFile.path)], subject: 'Nexc Database Backup');
  }
}

Future<ImportResult> importRawDatabase(AppDatabase db) async {
  final result = await FilePicker.platform.pickFiles();
  if (result == null || result.files.isEmpty || result.files.single.path == null) {
    return const ImportResult.ok();
  }
  final dbFolder = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dbFolder.path, 'nexc_database'));
  final shmFile = File(p.join(dbFolder.path, 'nexc_database-shm'));
  final walFile = File(p.join(dbFolder.path, 'nexc_database-wal'));

  try {
    await db.close();
    final selectedFile = File(result.files.single.path!);
    await selectedFile.copy(dbFile.path);
    if (await shmFile.exists()) await shmFile.delete();
    if (await walFile.exists()) await walFile.delete();
    return const ImportResult.ok();
  } catch (e) {
    return ImportResult.fail(e.toString());
  }
}
