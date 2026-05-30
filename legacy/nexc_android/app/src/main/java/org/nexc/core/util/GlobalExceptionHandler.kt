/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.util

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Process
import dagger.hilt.android.qualifiers.ApplicationContext
import org.nexc.core.activities.ErrorActivity
import org.nexc.core.db.repository.UserPreferencesRepository
import org.nexc.core.di.qualifiers.MainActivityClass
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.system.exitProcess


@Singleton
class GlobalExceptionHandler @Inject constructor(
    @param:ApplicationContext private val context: Context,
    @param:MainActivityClass private val mainActivityClass: Class<out Activity>,
    private val userPreferencesRepository: UserPreferencesRepository
) : Thread.UncaughtExceptionHandler {

    private var defaultHandler: Thread.UncaughtExceptionHandler? = null

    fun initialize() {
        // Get the current existing handler
        this.defaultHandler = Thread.getDefaultUncaughtExceptionHandler()

        // Set this class as the new handler
        Thread.setDefaultUncaughtExceptionHandler(this)
    }

    override fun uncaughtException(thread: Thread, exception: Throwable) {
        // Create a PendingIntent to restart the app
        val restartIntent = Intent(context, mainActivityClass).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0, // Request code
            restartIntent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        // Get user preferences to match current theme
        val materialMode = userPreferencesRepository.materialMode.value
        val themeMode = userPreferencesRepository.themeMode.value

        // Launch the ErrorActivity, passing the stack trace and the restart action
        val errorIntent = Intent(context, ErrorActivity::class.java).apply {
            putExtra(ErrorActivity.EXTRA_STACK_TRACE, getStackTrace(exception))
            putExtra(ErrorActivity.EXTRA_RESTART_PENDING_INTENT, pendingIntent)
            putExtra(ErrorActivity.EXTRA_THEME_MODE, themeMode)
            putExtra(ErrorActivity.EXTRA_MATERIAL_MODE, materialMode)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(errorIntent)

        defaultHandler?.uncaughtException(thread, exception)

        // Terminate the current process
        Process.killProcess(Process.myPid())
        exitProcess(10)
    }

    private fun getStackTrace(exception: Throwable): String {
        return java.io.StringWriter().also {
            exception.printStackTrace(java.io.PrintWriter(it))
        }.toString()
    }
}