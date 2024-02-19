// home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/authDB.dart';

class MapScreen extends StatefulWidget {
  static const title = 'Map';
  static const androidIcon = Icon(Icons.map);

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late FirebaseHelper dbHelper;
  late GoogleMapController mapController;
  late LatLng _center;
  @override
  void initState() {
    super.initState();
    dbHelper = FirebaseHelper();
    _center = LatLng(45.521563, -122.677433);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _center = LatLng(position.latitude, position.longitude);
      _animateCameraToCenter(); // Animate the camera to the new position
    } catch (e) {
      print('Error getting current position: $e');
    }
  }

  void _animateCameraToCenter() {
    mapController.animateCamera(CameraUpdate.newLatLng(_center));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.white, // Set the color you want for the overlay
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}