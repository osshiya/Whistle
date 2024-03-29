// report.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/report_screen.dart';
import 'package:flutter_app/models/bleDB.dart' as BleDB;
import 'package:flutter_app/utils/formatter.dart';

class ViewReportPage extends StatefulWidget {
  static const title = 'View Report';
  static const androidIcon = Icon(Icons.edit);

  const ViewReportPage({super.key, required this.id, required this.uid});

  final String id;
  final String uid;

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
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
      appBar: AppBar(
        title: const Text(ViewReportPage.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_data == null) Center(child: CircularProgressIndicator()),
            if (_data != null) ...[
              ListSection(
                title: _data?['title'] ?? _data?['type'] ?? '',
                subtitle: _data?['user'] ?? '',
                timestamp: formatTimestamp(_data?['timestamp'] ?? ''),
                description: _data?['desc'] ?? '',
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
          await dbBleHelper.getStoredReport(widget.uid, widget.id);
      setState(() {
        _data = data;
      });
    } catch (error) {
      print('Error retrieving data: $error');
    }
  }
}

class ReportPage extends StatefulWidget {
  static const title = 'View Report';
  static const androidIcon = Icon(Icons.edit);

  const ReportPage({super.key, required this.id, required this.uid});

  final String id;
  final String uid;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late BleDB.FirebaseHelper dbBleHelper;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
    _retrieveData();
  }

  Future<bool> deleteReport(String id) async {
    try {
      await dbBleHelper.deleteData(id, "report");
      return true; // Deletion successful
    } catch (error) {
      print('Error deleting report: $error');
      return false; // Deletion failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ReportPage.title),
        actions: <Widget>[
          IconButton(
            icon: ReportPage.androidIcon,
            tooltip: "Edit Report",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditReportPage(id: widget.id, uid: widget.uid)),
              ).then((_) {
                _retrieveData();
              });
            },
          ),
          IconButton(
              icon: Icon(Icons.delete),
              tooltip: "Delete Report",
              onPressed: () async {
                bool deletionResult = await deleteReport(widget.id);
                if (deletionResult) {
                  Navigator.pop(context);
                }
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_data == null) Center(child: CircularProgressIndicator()),
            if (_data != null) ...[
              ListSection(
                title: _data?['title'] ?? _data?['type'] ?? '',
                subtitle: _data?['user'] ?? '',
                timestamp: formatTimestamp(_data?['timestamp'] ?? ''),
                description: _data?['desc'] ?? '',
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
          await dbBleHelper.getStoredReport(widget.uid, widget.id);
      setState(() {
        _data = data;
      });
    } catch (error) {
      print('Error retrieving data: $error');
    }
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
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          // Text(
          //   subtitle,
          //   style: const TextStyle(
          //     fontSize: 16,
          //     color: Colors.grey,
          //   ),
          // ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
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

class CreateReportPage extends StatefulWidget {
  static const title = 'New Report';
  static const androidIcon = Icon(Icons.add);

  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  late BleDB.FirebaseHelper dbBleHelper;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbBleHelper = BleDB.FirebaseHelper();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void createReport(String title, String content) {
    dbBleHelper.createData("report", title, content);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(EditReportPage.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done),
                tooltip: "Create Report",
                onPressed: () {
                  createReport(_titleController.text, _descController.text);
                }),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: null, // Unlimited number of lines
                  keyboardType: TextInputType.multiline,
                ),
              ],
            )));
  }
}

class EditReportPage extends StatefulWidget {
  static const title = 'Edit Report';
  static const androidIcon = Icon(Icons.done);

  const EditReportPage({super.key, required this.id, required this.uid});

  final String id;
  final String uid;

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  late BleDB.FirebaseHelper dbBleHelper;
  Map<String, dynamic>? _data;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();

    dbBleHelper = BleDB.FirebaseHelper();

    _retrieveData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void updateReport(String title, String content) {
    dbBleHelper.updateData(widget.id, "report", title, content);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(EditReportPage.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done),
                tooltip: "Update Report",
                onPressed: () {
                  updateReport(_titleController.text, _descController.text);
                }),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_data == null) Center(child: CircularProgressIndicator()),
                  if (_data != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          formatTimestamp(_data?['timestamp']),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descController, // Predefined value
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ])));
  }

  Future<void> _retrieveData() async {
    try {
      Map<String, dynamic>? data =
          await dbBleHelper.getStoredReport(widget.uid, widget.id);
      setState(() {
        _data = data;
        _titleController.text = _data?['title'] ?? '';
        _descController.text = _data?['desc'] ?? '';
      });
    } catch (error) {
      print('Error retrieving data: $error');
    }
  }
}
