/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.settings

import android.net.Uri
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import org.nexc.core.util.BackupManager
import javax.inject.Inject

@HiltViewModel
class BackupViewModel @Inject constructor(
    private val backupManager: BackupManager
) : ViewModel() {

    suspend fun exportDatabase(uri: Uri) {
        backupManager.exportDatabase(uri)
    }

    suspend fun importDatabase(uri: Uri): Boolean {
        return try {
            backupManager.importDatabase(uri)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    suspend fun exportPlans(uri: Uri) {
        backupManager.exportPlans(uri)
    }

    suspend fun importPlans(uri: Uri): Boolean {
        return backupManager.importPlans(uri)
    }

    suspend fun exportExercises(uri: Uri) {
        backupManager.exportExercises(uri)
    }

    suspend fun importExercises(uri: Uri): Boolean {
        return backupManager.importExercises(uri)
    }
}
