// background_task.dart
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/rtDB.dart' as rtDB;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task executed');

    await updateCoordinates();

    return Future.value(true);
  });
}

Future<void> updateCoordinates() async {
  late AuthDB.FirebaseHelper dbAuthHelper;
  late rtDB.RtdbHelper rtdbHelper;
  rtdbHelper = rtDB.RtdbHelper();
  dbAuthHelper = AuthDB.FirebaseHelper();

  try {
    // Check if location services are enabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      print('Location services are not enabled');
      return;
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if it hasn't been granted
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Location permission denied');
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Check if the position is available
    if (position != null) {
      String? uid = await dbAuthHelper.getStoredUid();
      rtdbHelper.addUserWithCoordinates(
          uid, position.latitude, position.longitude);
    } else {
      print('Unable to retrieve current position');
    }
  } catch (e) {
    print('Error getting Location: $e');
  }
}
