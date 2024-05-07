// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:isolate';

// import 'package:fl_location/fl_location.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:permission_handler/permission_handler.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Permission.locationAlways.request();
//   await Permission.location.request();
//   runApp(const ExampleApp());
// }

// // The callback function should always be a top-level function.
// @pragma('vm:entry-point')
// void startCallback() {
//   // The setTaskHandler function must be called to handle the task in the background.
//   FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
// }

// class FirstTaskHandler extends TaskHandler {
//   StreamSubscription<Location>? _streamSubscription;

//   @override
//   void onStart(DateTime timestamp, SendPort? sendPort) async {
//     _streamSubscription = FlLocation.getLocationStream().listen((location) {
//       FlutterForegroundTask.updateService(
//         notificationTitle: 'My Location',
//         notificationText: '${location.latitude}, ${location.longitude}',
//       );

//       // Send data to the main isolate.
//       sendPort?.send(
//           {'latitude': location.latitude, 'longitude': location.longitude});
//     });
//   }

//   @override
//   void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}

//   @override
//   void onDestroy(DateTime timestamp, SendPort? sendPort) async {
//     await _streamSubscription?.cancel();
//   }
// }

// class ExampleApp extends StatelessWidget {
//   const ExampleApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const ExamplePage(),
//         '/resume-route': (context) => const ResumeRoutePage(),
//       },
//     );
//   }
// }

// class ExamplePage extends StatefulWidget {
//   const ExamplePage({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _ExamplePageState();
// }

// class _ExamplePageState extends State<ExamplePage> {
//   ReceivePort? _receivePort;

//   Future<void> _requestPermissionForAndroid() async {
//     if (!Platform.isAndroid) {
//       return;
//     }

//     // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//     // onNotificationPressed function to be called.
//     //
//     // When the notification is pressed while permission is denied,
//     // the onNotificationPressed function is not called and the app opens.
//     //
//     // If you do not use the onNotificationPressed or launchApp function,
//     // you do not need to write this code.
//     if (!await FlutterForegroundTask.canDrawOverlays) {
//       // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
//       await FlutterForegroundTask.openSystemAlertWindowSettings();
//     }

//     // Android 12 or higher, there are restrictions on starting a foreground service.
//     //
//     // To restart the service on device reboot or unexpected problem, you need to allow below permission.
//     if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
//       // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
//       await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//     }

//     // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
//     final NotificationPermission notificationPermissionStatus =
//         await FlutterForegroundTask.checkNotificationPermission();
//     if (notificationPermissionStatus != NotificationPermission.granted) {
//       await FlutterForegroundTask.requestNotificationPermission();
//     }
//   }

//   void _initForegroundTask() {
//     FlutterForegroundTask.init(
//       androidNotificationOptions: AndroidNotificationOptions(
//         foregroundServiceType: AndroidForegroundServiceType.LOCATION,
//         channelId: 'foreground_service',
//         channelName: 'Foreground Service Notification',
//         channelDescription:
//             'This notification appears when the foreground service is running.',
//         channelImportance: NotificationChannelImportance.LOW,
//         priority: NotificationPriority.LOW,
//         iconData: const NotificationIconData(
//           resType: ResourceType.mipmap,
//           resPrefix: ResourcePrefix.ic,
//           name: 'launcher',
//           backgroundColor: Colors.orange,
//         ),
//         buttons: [
//           const NotificationButton(
//             id: 'sendButton',
//             text: 'Send',
//             textColor: Colors.orange,
//           ),
//           const NotificationButton(
//             id: 'testButton',
//             text: 'Test',
//             textColor: Colors.grey,
//           ),
//         ],
//       ),
//       iosNotificationOptions: const IOSNotificationOptions(
//         showNotification: true,
//         playSound: false,
//       ),
//       foregroundTaskOptions: const ForegroundTaskOptions(
//         interval: 10000,
//         isOnceEvent: false,
//         autoRunOnBoot: true,
//         allowWakeLock: true,
//         allowWifiLock: true,
//       ),
//     );
//   }

//   Future<bool> _startForegroundTask() async {
//     // You can save data using the saveData function.
//     await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

//     // Register the receivePort before starting the service.
//     final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
//     final bool isRegistered = _registerReceivePort(receivePort);
//     if (!isRegistered) {
//       print('Failed to register receivePort!');
//       return false;
//     }

//     if (await FlutterForegroundTask.isRunningService) {
//       return FlutterForegroundTask.restartService();
//     } else {
//       return FlutterForegroundTask.startService(
//         notificationTitle: 'Foreground Service is running',
//         notificationText: 'Tap to return to the app',
//         callback: startCallback,
//       );
//     }
//   }

//   Future<bool> _stopForegroundTask() {
//     return FlutterForegroundTask.stopService();
//   }

//   bool _registerReceivePort(ReceivePort? newReceivePort) {
//     log('register recieve port');
//     if (newReceivePort == null) {
//       return false;
//     }

//     _closeReceivePort();

//     _receivePort = newReceivePort;
//     _receivePort?.listen((data) {
//       log('recieve data: $data');
//       if (data is int) {
//         print('eventCount: $data');
//       } else if (data is String) {
//         if (data == 'onNotificationPressed') {
//           Navigator.of(context).pushNamed('/resume-route');
//         }
//       } else if (data is DateTime) {
//         print('timestamp: ${data.toString()}');
//       }
//     });

//     return _receivePort != null;
//   }

//   void _closeReceivePort() {
//     _receivePort?.close();
//     _receivePort = null;
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _requestPermissionForAndroid();
//       _initForegroundTask();

//       // You can get the previous ReceivePort without restarting the service.
//       if (await FlutterForegroundTask.isRunningService) {
//         final newReceivePort = FlutterForegroundTask.receivePort;
//         _registerReceivePort(newReceivePort);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _closeReceivePort();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // A widget that prevents the app from closing when the foreground service is running.
//     // This widget must be declared above the [Scaffold] widget.
//     return WithForegroundTask(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Foreground Task'),
//           centerTitle: true,
//         ),
//         body: _buildContentView(),
//       ),
//     );
//   }

//   Widget _buildContentView() {
//     buttonBuilder(String text, {VoidCallback? onPressed}) {
//       return ElevatedButton(
//         onPressed: onPressed,
//         child: Text(text),
//       );
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           buttonBuilder('start', onPressed: _startForegroundTask),
//           buttonBuilder('stop', onPressed: _stopForegroundTask),
//         ],
//       ),
//     );
//   }
// }

// class ResumeRoutePage extends StatelessWidget {
//   const ResumeRoutePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Resume Route'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             // Navigate back to first route when tapped.
//             Navigator.of(context).pop();
//           },
//           child: const Text('Go back!'),
//         ),
//       ),
//     );
//   }
// }
