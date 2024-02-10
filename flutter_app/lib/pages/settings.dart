// settings_page.dart
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/auth/login_page.dart';

class SettingsPage extends StatefulWidget {
  static const title = 'Settings';
  static const androidIcon = Icon(Icons.settings);

  const SettingsPage({Key? key}) : super(key: key);
  // final User? user;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String uid; // Variable to store the UID

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
        (route) => false
      );
    } catch (e) {
      // Handle log-out errors
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
            // FutureBuilder<String>(
            //   future: _getStoredUid(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (!snapshot.hasData || snapshot.data == null) {
            //       return const Text('UID not found');
            //     } else {
            //       String uid = snapshot.data!;
            //       return FutureBuilder(
            //         future: _getUsername(uid),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const CircularProgressIndicator();
            //           } else if (snapshot.hasError) {
            //             return Text('Error: ${snapshot.error}');
            //           } else if (!snapshot.hasData || snapshot.data == null) {
            //             return const Text('Username not found');
            //           } else {
            //             String username = snapshot.data!;
            //             return Text('User Name: $username');
            //           }
            //         },
            //       );
            //     }
            //   },
            // ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _logout(),
              // onPressed: () {
              //   final snackBar = SnackBar(
              //     content: const Text('Logout!'),
              //     action: SnackBarAction(
              //       label: 'Undo',
              //       onPressed: () {
              //         // Some code to undo the change.
              //       },
              //     ),
              //   );
                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                // ScaffoldMessenger.of(context).showSnackBar(snackBar);
              // },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

//   Future<String> _getStoredUid() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     print(prefs.getString('uid'));
//     return prefs.getString('uid') ?? '';
//   }

//   Future<String> _getUsername(String uid) async {
//     DocumentSnapshot<Map<String, dynamic>> snapshot =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();

//     if (snapshot.exists) {
//       Map<String, dynamic>? data = snapshot.data();

//       if (data != null && data.containsKey('username')) {
//         return data['username'].toString();
//       }
//     }

//     // Return an empty string if the username is not found or if the snapshot doesn't exist
//     return '';
//   }
}
