// home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/bleDB.dart' as BleDB;

class ReportPage extends StatefulWidget {
  static const title = 'View Report';
  static const androidIcon = Icon(Icons.edit);

  const ReportPage({super.key, required this.id});

  final String id;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late BleDB.FirebaseHelper dbBleHelper;

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ReportPage.title),
        actions: <Widget>[
          IconButton(
            icon: ReportPage.androidIcon,
            tooltip: ReportPage.title,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditReportPage(id: widget.id)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: dbBleHelper.getStoredReport(widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(), // While data is loading
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Text('No data available');
                }

                Map<String, dynamic>? data =
                    snapshot.data; // Access snapshot data

                String title = data?['title'] ?? data?['type'] ?? '';
                String subtitle = data?['user'] ?? '';
                String description = data?['desc'] ?? '';
                int timestamp = data?['timestamp'] ?? '';

                DateTime? dateTime;
                String? formattedTime = "";
                if (timestamp != null) {
                  dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestamp);

                  // Format DateTime
                  formattedTime = dateTime != null
                      ? DateFormat('MMM dd, hh:mm a').format(dateTime)
                      : '';
                }

                return ListSection(
                    title: title,
                    subtitle: subtitle,
                    timestamp: formattedTime,
                    description: description);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListSection extends StatelessWidget {
  const ListSection({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.description,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String timestamp;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Add spacing between title and subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8), // Add spacing between subtitle and timestamp
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 4), // Add spacing between icon and timestamp
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Add spacing between timestamp and description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class EditReportPage extends StatefulWidget {
  static const title = 'Edit Report';
  static const androidIcon = Icon(Icons.done);

  const EditReportPage({super.key, required this.id});

  final String id;

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  late BleDB.FirebaseHelper dbBleHelper;

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(EditReportPage.title),
        actions: <Widget>[
          IconButton(
            icon: EditReportPage.androidIcon,
            tooltip: EditReportPage.title, onPressed: () {  },
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => const ReportPage(id: id)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("HELLO")
          ],
        ),
      ),
    );
  }
}