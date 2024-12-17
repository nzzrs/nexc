/*
 * Copyright (c) 2024 LibreFit
 *
 * This file is part of LibreFit
 *
 * LibreFit is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * LibreFit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with LibreFit.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.librefit.helpers

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import org.librefit.MainActivity
import org.librefit.R
import org.librefit.services.NotificationService
import org.librefit.util.formatTime


class NotificationHelper(context: Context) {
    companion object {
        const val CHANNEL_ID = "new_messages"
        const val NOTIFICATION_ID = 1001
    }

    private val appContext = context.applicationContext

    private var builder = NotificationCompat.Builder(appContext, CHANNEL_ID)

    private val pendingIntentMainActivity: PendingIntent = PendingIntent.getActivity(
        appContext,
        0,
        Intent(appContext, MainActivity::class.java).apply {
            // This flags allow to open an already running MainActivity (if any)
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        },
        PendingIntent.FLAG_IMMUTABLE
    )

    private val notificationManager =
        appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager


    init {
        createNotificationChannels()
        builder
            //TODO: remove hardcoded strings
            .setContentTitle("Ongoing workout")
            .setSmallIcon(R.drawable.ic_launcher_monochrome)
            .addAction(
                R.drawable.ic_pause,
                "Pause",
                createPendingIntent(NotificationService.PAUSE_CHRONOMETER)
            )
            .addAction(
                android.R.drawable.ic_media_play,
                "Resume",
                createPendingIntent(NotificationService.START_CHRONOMETER)
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntentMainActivity)
            .setAutoCancel(false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
    }


    private fun createNotificationChannels() {
        //val name = appContext.getString(R.string.channel_name)
        //val descriptionText = appContext.getString(R.string.channel_description)
        //TODO: move hardcoded strings in constants
        val name = "Workout and rest timers channel"
        val descriptionText = "This channel will be used to inform you about ongoing " +
                "workouts and when rest time is over"
        val importance = NotificationManager.IMPORTANCE_HIGH
        val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
            description = descriptionText
        }
        // Register the channel with the system.
        notificationManager.createNotificationChannel(channel)
    }

    fun createNotification(timeInSeconds: Int): Notification {
        return builder
            .setContentText("Time: ${formatTime(timeInSeconds)}")
            .build()
    }

    private fun createPendingIntent(action: String): PendingIntent {
        val intent = Intent(appContext, NotificationService::class.java).apply {
            this.action = action
        }
        return PendingIntent.getService(appContext, 0, intent, PendingIntent.FLAG_IMMUTABLE)
    }

    fun notify(timeInSeconds: Int): Notification {
        val notification = createNotification(timeInSeconds)
        notificationManager.notify(NOTIFICATION_ID, notification)
        return notification
    }
}