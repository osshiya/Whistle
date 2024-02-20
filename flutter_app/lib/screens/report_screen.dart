// home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/bleDB.dart' as BleDB;
import 'package:flutter_app/pages/report.dart';
import 'package:flutter_app/utils/formatter.dart';

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

class Lists extends StatefulWidget {
  final BleDB.FirebaseHelper dbBleHelper;

  const Lists({super.key, required this.dbBleHelper});

  @override
  State<Lists> createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  late BleDB.FirebaseHelper dbBleHelper;
  late Future<List<Map<String, dynamic>>?> _futureData;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    setState(() {
      _futureData = widget.dbBleHelper.getMyStoredReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // While data is loading
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available');
          }
          List<ListItemData> items = snapshot.data!.map((data) {
            // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
            String id = data['id'] ?? '';
            String uid = data['uid'] ?? '';
            String title = data?['title'] ?? data?['type'] ?? '';
            String subtitle = data?['desc'] ?? '';
            int timestamp = data?['timestamp'] ?? '';

            String formattedTime = formatTimestamp(timestamp);

            return ListItemData(
                id: id, uid:uid, title: title, subtitle: subtitle, time: formattedTime);
          }).toList();
          return ListSection(items: items, refreshCallback: _refreshList);
        },
      ),
    );
  }
}

class ListSection extends StatefulWidget {
  const ListSection({
    Key? key,
    required this.items,
    required this.refreshCallback,
  }) : super(key: key);

  final List<ListItemData> items;
  final VoidCallback refreshCallback;

  @override
  State<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<ListSection> {
  @override
  Widget build(BuildContext context) {
    return
        // RefreshIndicator(
        // onRefresh: _refreshList,
        // child:
        ListView.builder(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportPage(id: widget.items[index].id, uid: widget.items[index].uid,)),
            ).then((_) {
              widget.refreshCallback();
            });
          }, // Handle your onTap here.
        );
      },
      // ),
    );
  }
}

class ListItemData {
  final String id;
  final String uid;
  final String title;
  final String subtitle;
  final String time;

  ListItemData({
    required this.id,
    required this.uid,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
