// map_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/rtDB.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/friendDB.dart' as FriendDB;

class MapScreen extends StatefulWidget {
  static const title = 'Map';
  static const androidIcon = Icon(Icons.location_on);

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

Color generateColor(String input) {
  int hashCode = input.hashCode;
  double hue = (hashCode % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();
}

class _MapScreenState extends State<MapScreen> {
  late Timer _updateTimer;
  bool isFriendsListVisible = true;
  late AuthDB.FirebaseHelper dbHelper;
  late FriendDB.FirebaseHelper friendsHelper;
  late RtdbHelper rtdbHelper;
  late GoogleMapController mapController;
  late LatLng _center;
  late List<Map<String, dynamic>> friends;
  late List<Map<String, dynamic>> friendsLocations;
  late List<Map<String, dynamic>> friendsNames = [];
  late List<String> friendsList = [];
  late Set<Marker> _markers = Set<Marker>();
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    dbHelper = AuthDB.FirebaseHelper();
    friendsHelper = FriendDB.FirebaseHelper();
    rtdbHelper = RtdbHelper();
    friendsNames = [];
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      friendsNames = [];
      _updateMap();
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  Future<void> _updateMap() async {
    try {
      String uid = await dbHelper.getStoredUid();
      friends = await friendsHelper.getFriends(uid);
      friendsList.clear();

      for (var userMap in friends) {
        String uid = userMap["uid"];
        String name = await dbHelper.getUsername(uid);
        Map<String, dynamic> newMap = {
          "uid": uid,
          "name": name,
        };
        friendsNames.add(newMap);
        friendsList.add(uid);
      }

      _markers.clear();
      friendsLocations = await rtdbHelper.getUsersWithCoordinates(friendsList);

      for (var friendsMap in friendsLocations) {
        String friendUid = friendsMap["uid"];
        double latitude = friendsMap["latitude"];
        double longitude = friendsMap["longitude"];

        Color friendColor = generateColor(friendUid);
        String friendName = await friendsNames.firstWhere(
            (element) => element["uid"] == friendUid,
            orElse: () => {"name": ""})["name"];

        final Marker marker = Marker(
          markerId: MarkerId(friendUid),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: friendName,
            snippet: 'Lat: $latitude, Long: $longitude',
          ),
          icon: BitmapDescriptor.fromBytes(
              await _getMarkerIcon(friendColor, 20.0)),
        );

        _markers.add(marker);
      }

      setState(() {});
    } catch (e) {
      print('Error updating map: $e');
    }
  }

  Future<Uint8List> _getMarkerIcon(Color color, double radius) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final picture = recorder.endRecording();
    final img =
        await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    try {
      _updateMap();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _center = LatLng(position.latitude, position.longitude);
      _animateCameraToCenter();
      setState(() {});
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
            markers: _markers,
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.0, 0.0),
              zoom: 11.0,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Visibility(
              visible: isFriendsListVisible,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            'Your Friends',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friendsNames.length,
                        itemBuilder: (context, index) {
                          String friendName = friendsNames[index]["name"];
                          Color friendColor =
                              generateColor(friendsNames[index]["uid"]);

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: friendColor,
                                ),
                                SizedBox(height: 4.0),
                                Text(friendName),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isFriendsListVisible = !isFriendsListVisible;
              });
            },
            child: const Icon(Icons.people),
          ),
        ),
      ),
    );
  }
}
