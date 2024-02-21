// signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/authDB.dart';
import 'package:flutter_app/auth/login_page.dart';

class SignupPage extends StatefulWidget {
  static const title = 'Sign Up';
  static const androidIcon = Icon(Icons.lock);
  static const iosIcon = Icon(CupertinoIcons.lock);

  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late FirebaseHelper dbHelper;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _revealPassword = false;
  bool _revealConfirmPassword = false;

  bool passwordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _signup(BuildContext context) async {
    try {
      dbHelper = FirebaseHelper();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Store additional user data to Firebase
      await dbHelper.storeUserData(_nameController.text.trim(), userCredential);

      _navigateToLoginPage(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print("Error during signup: $e");
    }
  }

  // Navigate to Login Page
  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
  }

  void _navigateBackToLoginPage(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SignupPage.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                // Change label color
                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B39C0)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B39C0)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: !_revealPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B39C0)),
                suffixIcon: IconButton(
                    icon: Icon(
                      _revealPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _revealPassword = !_revealPassword;
                      });
                    }),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_revealConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                // Change label color
                prefixIcon: Icon(Icons.lock, color: Color(0xFF2B39C0)),
                suffixIcon: IconButton(
                    icon: Icon(
                      _revealConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _revealConfirmPassword = !_revealConfirmPassword;
                      });
                    }),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF2B39C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              onPressed: () {
                if (passwordsMatch()) {
                  // Passwords match, reveal the password
                  _signup(context);
                } else {
                  // Passwords do not match
                  print('Passwords do not match');
                }
              },
              child: const Text(SignupPage.title),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _navigateBackToLoginPage(context),
              child: const Text('Back to Login',
                  style: TextStyle(color: Color(0xFF2B39C0))),
            ),
          ],
        ),
      ),
    );
  }
}
