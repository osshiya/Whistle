// home_screen.dart
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/db.dart';

class ReportScreen extends StatefulWidget {
  static const title = 'Reports';
  static const androidIcon = Icon(Icons.warning);

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
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
