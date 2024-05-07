package com.example.geo_native

import android.app.Service
import android.content.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.os.Budle
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.ViewModewProvider
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.laucnhIn
import kotlinx.coroutines.flow.onEach

class LocationService() : Service() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private lateinit var locationClient: LocationClient
 
    private val binder = LocalBinder()
    private var locationCallback: LocationCallback? = null
 
    inner class LocalBinder : Binder() {
        fun getService(): LocationService = this@LocationService
    }
 
    override fun onBind(intent: Intent?): IBinder? {
        return binder
    }
 
    fun setLocationCallback(callback: LocationCallback) {
        locationCallback = callback
    }
 
    override fun onCreate() {
        super.onCreate()
        locationClient = DefaultLocationClient(
            applicationContext,
            LocationServices.getFusedLocationProviderClient(applicationContext)
        )
    }
 
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> start()
        }
        return super.onStartCommand(intent, flags, startId)
    }

    private fun start() {
        val notification = NotificationCompat.Builder(this, "location")
            .setContentTitle("Location service started")
            .setContentText("Location service is running")
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setOngoing(true)

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            locationClient.getLocationUpdates(10000L)
            .catch {e -> e.printStacktrace() }
            .onEach {location -> 
            val lat = location.latitude
            val long = location.longitude
            Log.i("datails", "lat lng ${lat} ${long}")
            locationCallback?.onLocationUpdated(lat, long)
            // callback?.onDataReceived("lat lng ${lat} ${long}")

            //attachEvent?.success("lat lng ${lat} ${long}")
            val updateNotification = notification.setContentText("Location ($lat, $long)")
            notificationManager.notify(1, updateNotification.build())
        
        }
        .laucnhIn(serviceScope)

        startForeGround(1, notification.build())
    }

    private fun stop(){
        //callback?.onDataStopped("stop")
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            stopForeGround(STOP_FOREGROUND_DETACH)
    } else {
        stopForeGround(true)
    } attachEvent?.endOfStream()
    attachEvent = null
    stopSelf()
 }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }

    companion object {
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
    }
}