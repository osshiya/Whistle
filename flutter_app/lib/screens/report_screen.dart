// report_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/pages/report.dart';
import 'package:flutter_app/models/bleDB.dart' as BleDB;
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
        padding: const EdgeInsets.only(bottom: 32.0, right: 32.0, left: 32.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ReportSection(name: "My Reports"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateReportPage()),
                      ).then((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const HomePage(
                              selectedIndex: 3,
                            ),
                          ),
                          (route) => false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shadowColor: Color(0xFF000000),
                        shape: CircleBorder(),
                        elevation: 8),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Lists(dbBleHelper: dbBleHelper)
            ]));
  }
}

class ReportSection extends StatefulWidget {
  const ReportSection({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<ReportSection> createState() => _ReportSectionState();
}

class _ReportSectionState extends State<ReportSection> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
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
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        padding: EdgeInsets.all(13.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 6.4,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.white,
        ),
        child: FutureBuilder<List<Map<String, dynamic>>?>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center( child: Text('No data available'));
            }
            List<ListItemData> items = snapshot.data!.map((data) {
              String id = data['id'] ?? '';
              String uid = data['user'] ?? '';
              String title = data['title'] ?? data['type'] ?? '';
              String subtitle = data['desc'] ?? '';
              int timestamp = data['timestamp'] ?? '';

              String formattedTime = formatTimestamp(timestamp);

              return ListItemData(
                  id: id,
                  uid: uid,
                  title: title,
                  subtitle: subtitle,
                  time: formattedTime);
            }).toList();
            return ListSection(items: items, refreshCallback: _refreshList);
          },
        ),
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
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          subtitle: Text(
            widget.items[index].subtitle,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportPage(
                        id: widget.items[index].id,
                        uid: widget.items[index].uid,
                      )),
            ).then((_) {
              widget.refreshCallback();
            });
          },
        );
      },
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
