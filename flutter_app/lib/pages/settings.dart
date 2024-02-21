// settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  static const title = 'Settings';
  static const androidIcon = Icon(Icons.settings);

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String uid;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Settings!',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _logout(),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
