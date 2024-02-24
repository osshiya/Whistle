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
  @pragma('vm:entry-point')

  static void updateCoordinatesIsolate() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      log("Firebase initialized successfully");
      AuthDB.FirebaseHelper dbAuthHelper = AuthDB.FirebaseHelper();
      rtDB.RtdbHelper rtdbHelper = rtDB.RtdbHelper();
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        log('Location services are not enabled');
        return;

      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (position != null) {
        String? uid = await dbAuthHelper.getStoredUid();
        await rtdbHelper.addUserWithCoordinates(
            uid, position.latitude, position.longitude);
        log('User coordinates updated successfully');
      } else {
        log('Unable to retrieve current position');
      }
    } catch (e) {
      log('Error updating user coordinates: $e');
    }
  }

  @pragma('vm:entry-point')
  static Function callbackDispatcher(RootIsolateToken rootIsolateToken) {
    return updateCoordinatesIsolate;
  }
}
