package com.dcsec.quickcargoo
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log


class MyBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("MyBootReceiver", "Device rebooted, starting background service...")

            // Start the Flutter background service
            val serviceIntent = Intent(context, MyBackgroundService::class.java)
            context.startForegroundService(serviceIntent)
        }
    }
}