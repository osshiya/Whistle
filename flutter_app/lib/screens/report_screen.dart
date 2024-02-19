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
import 'package:flutter_app/pages/report.dart';

class ReportScreen extends StatefulWidget {
  static const title = 'Reports';
  static const androidIcon = Icon(Icons.warning);

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late BleDB.FirebaseHelper dbBleHelper;

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        // Adjust the value as needed
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Lists(dbBleHelper: dbBleHelper)]));
  }
}

class Lists extends StatelessWidget {
  final BleDB.FirebaseHelper dbBleHelper;

  const Lists({super.key, required this.dbBleHelper});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>?>(
        future: dbBleHelper.getStoredReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // While data is loading
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('No data available');
          }
          List<ListItemData> items = snapshot.data!.map((data) {
            // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
            String title = data?['title'] ?? data?['type'] ?? '';
            String subtitle = data?['desc'] ?? '';
            int timestamp = data?['timestamp'] ?? '';
            String id = data['id'] ?? '';

            DateTime? dateTime;
            String? formattedTime = "";
            if (timestamp != null) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

              // Format DateTime
              formattedTime = dateTime != null
                  ? DateFormat('MMM dd, hh:mm a').format(dateTime)
                  : '';
              print(formattedTime);
            }

            return ListItemData(
              title: title,
              subtitle: subtitle,
              time: formattedTime,
              id: id
            );
          }).toList();
          return ListSection(items: items);
        },
      ),
    );
  }
}

class ListSection extends StatefulWidget {
  const ListSection({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<ListItemData> items;
  @override
  State<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<ListSection> {
  void _navigateToListView(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.items[index].title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.items[index].time,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey, // Adjust color as needed
                ),
              ),
            ],
          ),
          subtitle: Text(
            widget.items[index].subtitle,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.grey, // Adjust color as needed
            ),
          ),
          onTap: () {
            _navigateToListView(widget.items[index].id);
          }, // Handle your onTap here.
        );
      },
    );
  }
}

class ListItemData {
  final String title;
  final String subtitle;
  final String time;
  final String id;

  ListItemData(
      {required this.title, required this.subtitle, required this.time, required this.id});
}
