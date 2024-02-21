// emergency.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/models/bleDB.dart' as BleDB;
import 'package:flutter_app/utils/formatter.dart';

class EmergencyPage extends StatefulWidget {
  static const title = 'Emergency';
  static const androidIcon = Icon(Icons.emergency);

  const EmergencyPage({super.key, required this.id, required this.uid});

  final String id;
  final String uid;

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late BleDB.FirebaseHelper dbBleHelper;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
    _retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF5554),
      appBar: AppBar(
        title: const Text(EmergencyPage.title,
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF5554),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.call),
              tooltip: "Call Emergency",
              onPressed: () async {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 180.0,
              height: 180.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 18.0 * 0.4),
              ),
              child: CircleAvatar(
                radius: 180.0 / 2,
                backgroundColor: randomColor(),
                child: Text(
                  getInitials("name"),
                  style: const TextStyle(
                    fontSize: 180.0 * 0.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Text("SOS",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 180.0 * 0.4,
                    color: Colors.white)),
            if (_data == null) // Show loading indicator if data is null
              Center(child: CircularProgressIndicator()),
            if (_data != null) ...[
              // Show data if available
              MessageSection(
                title: _data?['title'] ?? _data?['type'] ?? '',
                subtitle: _data?['user'] ?? '',
                timestamp: formatTimestamp(_data?['timestamp'] ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _retrieveData() async {
    try {
      // Retrieve data from the database
      Map<String, dynamic>? data =
          await dbBleHelper.getStoredEmergency(widget.uid, widget.id);
      setState(() {
        _data = data; // Update the state with the new data
      });
    } catch (error) {
      // Handle errors
      print('Error retrieving data: $error');
    }
  }
}

class MessageSection extends StatelessWidget {
  const MessageSection({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$subtitle has activated an emergency alert. He/She may be in danger right now.",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
