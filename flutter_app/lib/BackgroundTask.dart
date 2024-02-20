// BackgroundTask.dart
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_app/models/rtDB.dart' as rtDB;
import 'package:flutter_app/models/authDB.dart' as AuthDB;

import 'firebase_options.dart';
class BackgroundTask {

  static Future<void> updateCoordinatesIsolate() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    log("I'm Crying");
    // Initialize Firebase in the background task
    late AuthDB.FirebaseHelper dbAuthHelper;
    late rtDB.RtdbHelper rtdbHelper;
    dbAuthHelper = AuthDB.FirebaseHelper();
    rtdbHelper = rtDB.RtdbHelper();
    log("Update!1");
    try {
      // Check if location services are enabled
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        print('Location services are not enabled');
        return;
      }
      log("Update!2");
          // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      log("Update!3");

      if (position != null) {
        String? uid = await dbAuthHelper.getStoredUid();
        await rtdbHelper.addUserWithCoordinates(uid, position.latitude, position.longitude);
          } else {
            print('Unable to retrieve current position');
          }
        } catch (e) {
          print('Error getting Location: $e');
        }
    log("Update!4");

  }

  @pragma('vm:entry-point')
  static Function callbackDispatcher(RootIsolateToken rootIsolateToken) {
    return updateCoordinatesIsolate;
  }
}


