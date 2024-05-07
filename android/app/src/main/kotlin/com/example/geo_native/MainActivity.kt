package com.example.geo_native
import java.util.Objects
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.andorid.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterFragmentActivity(), LocationCallback {

    private val REQUIRED_PERMISSIONS = mutableListOf(
        android.Manifest.permission.ACCESS_COARSE_LOCATION,
        android.Manifest.permission.ACCESS_FINE_LOCATION,
    ).apply {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            add(android.Manifest.permission.POST_NOTIFICATIONS)
    }
}.toTypedArray()

private val networkWventChannel = "comn.example.locationconnetivity"
private val attachEvent: EventChannel.EventSink? = null

private val requestPermissionLauncher = registerForActivityResult(
    ActivityResultContracts.RequestMultiplePermissions()
) {
    isGranted -> Log.i("isGranted", isGranted.toString())
    if( isGranted.containsValue(false)) {
        Toast.makeText(this, "Permission not granted", Toast.LENGTH_SHORT).show()
} else {
    val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    varl is Enabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    if(isEnabled){
        Intent(applicationContext, locationService:: class.java).apply {
            action = LocationService.ACTION_START
            startService(this)
        }

        val serviceIntent = Intent(applicationContext, LocationService::class.java).apply{
            action  = LocationService.ACTION_START
        }
        startService(serviceIntent)
        bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
    } else {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        startActivity(intent)
        Toast.makeText(this@MainActivity, "Enable location", Toast.LENGTH_SHORT).show()
    }
}
}

private val locaionService: LocationService? = null
private val isServiceBound = false

private val serviceConnection = object : serviceConnection {
    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        val binder = service as LocationService.LocalBinder
        locaionService = binder.getService()
        locationService?.setLocationCallback(this@MainActivity)
        isServiceBound = true
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        locationService = null
        isServiceBound = false
    }
}

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val channel = NotificationChannel("location", "Location", NotificationManager.IMPORTANCE_HIGH)

        val notificationManger = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }   }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, networkEventChannel).setStreamHandler(
            object : EventChannel.StreamHandler(NetworkStreamHandler(this, lifecycle))


            EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, networkEventChannel).setStreamHandler(
                object : EventChannel.StreamHandler{
                    override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                        Log.w("TAG_NAME", "ADDING LISTENER")
                        attachEvent = events
                }
               
                override fun onCancel(args: Any?) {
                    Log.w("TAG_NAME", "CANCELLING LISTENER")
                    attachEvent = null
                    println("StreamHandler - onCancel")
                }
            })

            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "locationPlatform").setMethodCallHandler { call, result ->
               when (call.method){
                "getLocation" -> {
                    requestPermissionLauncher.launch(REQUIRED_PERMISSIONS)
                }

                "stopLocation" -> {
                    Intent(applicationContext, LocationService::class.java).apply {
                        action = LocationService.ACTION_STOP
                        startService(this)
                    }
               }
               else -> result.notImplemented()
            }
        }
    }
}

override fun onLocationUpdated(latitude: Double, longitude: Double) {  
    runonUiThread {
        Log.i("attachevents", "${attachEvent}",)
        Toast.makeText(this, "lat lng ${latitude} ${longitude}", Toast.LENGTH_SHORT).show()
        attachEvent?.success("${latitude} ${longitude}")     
    }}
        