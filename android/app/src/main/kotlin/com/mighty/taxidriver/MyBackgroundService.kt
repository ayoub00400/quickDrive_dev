package com.dcsec.quickcargoo

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class MyBackgroundService : Service() {
    override fun onCreate() {
        super.onCreate()
        Log.d("MyBackgroundService", "Service created")
        // Additional setup if needed
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("MyBackgroundService", "Service started")
        // Run tasks here (e.g., Flutter background tasks)
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("MyBackgroundService", "Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null // Not binding this service to a UI
    }
}