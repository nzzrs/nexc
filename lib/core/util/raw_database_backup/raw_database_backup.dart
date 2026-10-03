/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

export 'raw_database_backup_unsupported.dart'
    if (dart.library.js_interop) 'raw_database_backup_web.dart'
    if (dart.library.io) 'raw_database_backup_native.dart';
