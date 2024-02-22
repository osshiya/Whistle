import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:isolate';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/auth/login_page.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/pages/report.dart';
import 'package:flutter_app/pages/emergency.dart';
import 'package:flutter_app/BackgroundTask.dart' as bg;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void backGroundTask(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AndroidAlarmManager.periodic(const Duration(minutes: 15), 0,
      bg.BackgroundTask.updateCoordinatesIsolate,
      exact: true,
      wakeup: true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AndroidAlarmManager.initialize();
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  Isolate.spawn(backGroundTask, rootIsolateToken);

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings notificationSettings =
      await firebaseMessaging.requestPermission();
  if (notificationSettings.authorizationStatus ==
      AuthorizationStatus.authorized) {
    await firebaseMessaging.setAutoInitEnabled(true);
    print('User granted permission');
  } else if (notificationSettings.authorizationStatus ==
      AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  [
    Permission.location,
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.notification
  ].request().then((status) {
    runApp(MaterialApp(
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
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type",
    // navigate to a "type" screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (mounted) {
      // Check if the state is still mounted
      if (message.data["type"] == "Emergency") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmergencyPage(id: message.data["id"], uid: message.data["uid"]),
          ),
        );
      } else if (message.data["type"] == "Report") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewReportPage(
                id: message.data["id"], uid: message.data["uid"]),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AuthenticationWrapper();
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
