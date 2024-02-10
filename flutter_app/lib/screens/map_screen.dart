// home_screen.dart
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/db.dart';

class MapScreen extends StatefulWidget {
  static const title = 'Map';
  static const androidIcon = Icon(Icons.map);

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late FirebaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = FirebaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Hello World");
  }
}