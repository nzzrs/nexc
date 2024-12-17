package org.librefit.services

import android.app.Service
import android.content.Intent
import android.os.IBinder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.librefit.MainApplication
import org.librefit.helpers.NotificationHelper

class NotificationService : Service() {


    companion object {
        const val START_CHRONOMETER = "START_CHRONOMETER"
        const val PAUSE_CHRONOMETER = "PAUSE_CHRONOMETER"
        const val STOP_CHRONOMETER = "STOP_CHRONOMETER"

        private val _timeElapsed = MutableStateFlow(0)
        val timeElapsed: StateFlow<Int> = _timeElapsed

        private val _isPaused = MutableStateFlow(false)
        val isPaused: StateFlow<Boolean> = _isPaused
    }


    private var notificationJob: Job? = null
    private var notificationHelper = MainApplication.notificationHelper


    override fun onCreate() {
        super.onCreate()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            START_CHRONOMETER -> startChronometer()
            PAUSE_CHRONOMETER -> pauseChronometer()
            STOP_CHRONOMETER -> stopChronometer()
        }
        return START_STICKY
    }

    private fun startChronometer() {

        val startTime = System.currentTimeMillis()
        val pastTime = _timeElapsed.value

        _isPaused.value = false

        notificationJob = CoroutineScope(Dispatchers.Main).launch {
            while (!_isPaused.value) {
                val currentTime = System.currentTimeMillis()

                _timeElapsed.value = (currentTime - startTime).toInt() / 1000 + pastTime

                notificationHelper.notify(_timeElapsed.value)

                delay(1000)
            }
        }
        notificationJob?.start()

        startForeground(
            NotificationHelper.NOTIFICATION_ID,
            notificationHelper.notify(_timeElapsed.value)
        )
    }

    private fun pauseChronometer() {
        _isPaused.value = true
    }

    fun stopChronometer() {
        pauseChronometer()
        notificationJob?.cancel()
        _timeElapsed.value = 0
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }
}