import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// Send email verification
Future<void> sendEmailVerification() async {
  User? user = _auth.currentUser;

  if (user != null && !user.emailVerified) {
    try {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
    } catch (e) {
      print('Error sending verification email: $e');
      // Handle error sending verification email
    }
  }
}

// Check if email is verified
bool isEmailVerified() {
  User? user = _auth.currentUser;

  if (user != null) {
    return user.emailVerified;
  }

  return false;
}
