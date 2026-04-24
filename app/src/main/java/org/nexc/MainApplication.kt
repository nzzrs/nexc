/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2024-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import org.nexc.core.db.repository.DatasetRepository
import org.nexc.core.util.GlobalExceptionHandler
import javax.inject.Inject

@HiltAndroidApp
class MainApplication : Application() {
    @Inject
    lateinit var globalExceptionHandler: GlobalExceptionHandler

    @Inject
    lateinit var datasetRepository: DatasetRepository

    override fun onCreate() {
        super.onCreate()
        // Setup global exception handler
        globalExceptionHandler.initialize()

        // Update dataset on each app update
        datasetRepository.updateDatasetOnAppUpdate()
    }
}