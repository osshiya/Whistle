// settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/auth/login_page.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;

class SettingsPage extends StatefulWidget {
  static const title = 'Settings';
  static const androidIcon = Icon(Icons.settings);

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AuthDB.FirebaseHelper dbAuthHelper;
  late String uid;
  Map<String, dynamic>? _data;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emergencyNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbAuthHelper = AuthDB.FirebaseHelper();

    _retrieveData();
  }

  Future<void> _retrieveData() async {
    try {
      uid = await dbAuthHelper.getStoredUid();
      Map<String, dynamic>? data = await dbAuthHelper.getUserData(uid);
      setState(() {
        _data = data;
        _nameController.text = _data?['name'] ?? '';
        _emergencyNumberController.text = _data?['emergencyNumber'] ?? '';
      });
    } catch (error) {
      print('Error retrieving data: $error');
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      // Remove the UID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('uid');

      // Show SnackBar on successful logout
      _showLogoutSnackbar();

      // Navigate to Login Page
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  // Method to show a SnackBar
  void _showLogoutSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout successful!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SettingsPage.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Name:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your new name',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Emergency Number:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _emergencyNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter your new emergency number',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Save the changes
                String newName = _nameController.text;
                String newEmergencyNumber = _emergencyNumberController.text;
                dbAuthHelper.updateUserData(newName, newEmergencyNumber);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Changes saved successfully')),
                );
              },
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF2B39C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  // side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _logout(),
              child: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFFF5554),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  // side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
