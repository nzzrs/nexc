/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.features.settings

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import kotlinx.coroutines.launch
import org.nexc.R
import org.nexc.core.components.NexcButton
import org.nexc.core.components.NexcScaffold

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun BackupScreen(
    navigateBack: () -> Unit,
    viewModel: BackupViewModel = hiltViewModel()
) {
    val scope = rememberCoroutineScope()
    val snackbarHostState = remember { SnackbarHostState() }
    val context = LocalContext.current

    val exportDbLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/x-sqlite3"),
        onResult = { uri -> uri?.let { scope.launch { viewModel.exportDatabase(it) } } }
    )

    val importDbLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument(),
        onResult = { uri ->
            uri?.let {
                scope.launch {
                    val success = viewModel.importDatabase(it)
                    if (success) {
                        snackbarHostState.showSnackbar(context.getString(R.string.import_success))
                    }
                }
            }
        }
    )

    val exportPlansLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/json"),
        onResult = { uri -> uri?.let { scope.launch { viewModel.exportPlans(it) } } }
    )

    val importPlansLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument(),
        onResult = { uri ->
            uri?.let {
                scope.launch {
                    val success = viewModel.importPlans(it)
                    if (success) {
                        snackbarHostState.showSnackbar(context.getString(R.string.import_success))
                    }
                }
            }
        }
    )

    val exportExercisesLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/json"),
        onResult = { uri -> uri?.let { scope.launch { viewModel.exportExercises(it) } } }
    )

    val importExercisesLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument(),
        onResult = { uri ->
            uri?.let {
                scope.launch {
                    val success = viewModel.importExercises(it)
                    if (success) {
                        snackbarHostState.showSnackbar(context.getString(R.string.import_success))
                    }
                }
            }
        }
    )

    NexcScaffold(
        title = androidx.compose.ui.text.AnnotatedString(stringResource(R.string.backup_and_restore)),
        navigateBack = navigateBack,
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                BackupSection(
                    title = stringResource(R.string.database),
                    description = stringResource(R.string.database_backup_desc),
                    onExport = { exportDbLauncher.launch("nexc_backup.db") },
                    onImport = { importDbLauncher.launch(arrayOf("*/*")) }
                )
            }

            item {
                BackupSection(
                    title = stringResource(R.string.workout_plans),
                    description = stringResource(R.string.plans_backup_desc),
                    onExport = { exportPlansLauncher.launch("nexc_plans.json") },
                    onImport = { importPlansLauncher.launch(arrayOf("application/json")) }
                )
            }

            item {
                BackupSection(
                    title = stringResource(R.string.exercises),
                    description = stringResource(R.string.exercises_backup_desc),
                    onExport = { exportExercisesLauncher.launch("nexc_exercises.json") },
                    onImport = { importExercisesLauncher.launch(arrayOf("application/json")) }
                )
            }
        }
    }
}

@Composable
private fun BackupSection(
    title: String,
    description: String,
    onExport: () -> Unit,
    onImport: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(text = title, style = MaterialTheme.typography.titleLarge)
        Text(text = description, style = MaterialTheme.typography.bodyMedium)
        
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            NexcButton(
                onClick = onExport,
                text = stringResource(R.string.export),
                icon = painterResource(R.drawable.ic_exit_to_app),
                modifier = Modifier.fillMaxWidth()
            )
            NexcButton(
                onClick = onImport,
                text = stringResource(R.string.import_label),
                icon = painterResource(R.drawable.ic_open_new),
                modifier = Modifier.fillMaxWidth(),
                elevated = false
            )
        }
    }
}
