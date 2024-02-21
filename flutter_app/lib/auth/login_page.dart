// login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/auth/signup_page.dart';
import 'package:flutter_app/auth/reset_password.dart';
import 'package:flutter_app/pages/home.dart';

class LoginPage extends StatefulWidget {
  static const title = 'ProjectName';
  static const androidIcon = Icon(Icons.lock);
  static const iosIcon = Icon(CupertinoIcons.lock);

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late String uid; // Variable to store the UID

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final newUid = userCredential.user!.uid;
      setState(() {
        uid = newUid;
      });

      // Save the UID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', uid);
      prefs.setString('email', _emailController.text);

      // Navigate to Home Page
      _navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      // Handle login errors
      print('Error during login: $e');
    }
  }

  // Navigate to Home Page
  void _navigateToHomePage() async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false);
  }

  // Navigate to Signup Page
  void _navigateToSignupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  // Navigate to Reset Password
  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPassword()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          LoginPage.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF546EFE),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF2B39C0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusted
        children: [
          Image.asset(
            'assets/rafiki.png',
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(44.0),
              margin: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(64.0),
                  topRight: Radius.circular(64.0),
                ),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                      // Change label color
                      prefixIcon: Icon(Icons.email, color: Color(0xFF2B39C0)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF2B39C0)),
                      // Change label color
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF2B39C0)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF2B39C0), width: 2.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    obscureText: true,
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
                    onPressed: _login,
                    child: const Text("Sign In"),
                  ),
                  // const SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: _navigateToSignupPage,
                        child: const Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sign up here',
                                style: TextStyle(color: Color(0xFF2B39C0)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _navigateToResetPassword,
                        child: const Text(
                          'Forget Password',
                          style: TextStyle(color: Color(0xFF2B39C0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
