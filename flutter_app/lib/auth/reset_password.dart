// signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ResetPassword extends StatefulWidget {
  static const title = 'Reset Password';
  static const androidIcon = Icon(Icons.lock);
  static const iosIcon = Icon(CupertinoIcons.lock);

  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  // Function to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } catch (e) {
      // Handle password reset email errors
      print('Error sending password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ResetPassword.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: Color(0xFF2B39C0)), // Change label color
                prefixIcon: Icon(Icons.email, color: Color(0xFF2B39C0)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF2B39C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                  // side: BorderSide(color: Colors.blue),
                ),
              ),
              onPressed: () => sendPasswordResetEmail(
                _emailController.text,
              ),
              child: const Text(ResetPassword.title),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
