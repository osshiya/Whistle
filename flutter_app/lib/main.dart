import 'dart:isolate';
import 'dart:ui';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_app/auth/login_page.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:wakelock/wakelock.dart';

import 'BackgroundTask.dart' as bg;
void backGroundTask(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken!);
  // Initialize Firebase in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Now, spawn another isolate for periodic tasks
  // Now, spawn another isolate for periodic tasks
  AndroidAlarmManager.periodic(const Duration(minutes: 15), 0, bg.BackgroundTask.updateCoordinatesIsolate,
    exact: true, // Ensure precise timing
    wakeup: true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AndroidAlarmManager.initialize();
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  Isolate.spawn(backGroundTask, rootIsolateToken);



  [
    Permission.location,
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ].request().then((status) {
    runApp(const MyApp());
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GDSC 2024',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You can show a loading indicator if needed
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // User is logged in
          return const HomePage();
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}