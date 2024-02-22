// emergency.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;
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
  late AuthDB.FirebaseHelper dbAuthHelper;
  late BleDB.FirebaseHelper dbBleHelper;
  Map<String, dynamic>? _data;
  String username = '';

  @override
  void initState() {
    super.initState();
    dbAuthHelper = AuthDB.FirebaseHelper();
    dbBleHelper = BleDB.FirebaseHelper();
    _retrieveData();
  }

  void _makePhoneCall(String fid) async {
    String phoneNumber = await dbAuthHelper.getEmergencyNumber(fid);
    String telScheme = 'tel:$phoneNumber';
    try {
      await launchUrl(Uri.parse(telScheme));
    } catch (e) {
      throw 'Could not launch $telScheme';
    }
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
              onPressed: () async {
                _makePhoneCall(widget.uid);
              }),
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
                  getInitials(username),
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
            if (_data == null) Center(child: CircularProgressIndicator()),
            if (_data != null) ...[
              MessageSection(
                title: _data?['title'] ?? _data?['type'] ?? '',
                subtitle: username,
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
      Map<String, dynamic>? data =
          await dbBleHelper.getStoredEmergency(widget.uid, widget.id);
      String name = await dbAuthHelper.getUsername(widget.uid);
      setState(() {
        _data = data;
        username = name;
      });
    } catch (error) {
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
