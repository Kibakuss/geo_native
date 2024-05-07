import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const locationChannel = MethodChannel('locationPlatform');

  final _eventChannel = const EventChannel('com.example.locationconnectivity');

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      print('FlutterRecieved: $event');
    }, onError: (Object obj, StackTrace st) {
      print('FlutterError: $obj');
      print('FlutterError: $st');
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            TextButton(
              onPressed: () {
                try {
                  locationChannel.invokeMethod('getLocation');
                } on PlatformException catch (e) {
                  print('Failed to get location: ${e.message}');
                }
              },
              child: Text('Get location'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                try {
                  locationChannel.invokeMethod('stopLocation');
                } on PlatformException catch (e) {
                  print('Failed to stop location: ${e.message}');
                }
              },
              child: Text('Stop location'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Inc{rement',
        child: const Icon(Icons.add),
      ),
    );
  }
}
