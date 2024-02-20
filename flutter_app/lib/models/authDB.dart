import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class FirebaseHelper {
  Future<String> getStoredUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUid = prefs.getString('uid');

    if (storedUid != null) {
      print('uid: $storedUid');
    } else {
      print('UID not found in SharedPreferences');
    }
    return storedUid ?? '';
  }

  Future<String> getStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail != null) {
      print('email: $storedEmail');
    } else {
      print('Email not found in SharedPreferences');
    }
    return storedEmail ?? '';
  }

  Future<String> getUsername(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();

      if (data != null && data.containsKey('username')) {
        return data['username'].toString();
      }
    }

    // Return an empty string if the username is not found or if the snapshot doesn't exist
    return '';
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    if (uid != null && uid.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();
      // Further processing with the snapshot

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();

        // if (data != null && data.containsKey('username')) {
        //   return data['username'].toString();
        // }
        return data;
      } else {
        // Handle the case where uid is null or empty
        print('Snapshot is null or empty');
        return null;
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
    // Return an empty string if the username is not found or if the snapshot doesn't exist
    // return '';
  }

  Future<List<String>> getFriendsFCMTokens(String userId) async {
    String uid = await getStoredUid();
    List<String> friendsTokens = [];
    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null) {
        List<dynamic>? friends = userData["friends"] as List<dynamic>?;
        for (String friend in friends!) {
          // getUid
          // friendsTokens
          //     .add(friend); // Assuming each friend is stored as an FCM token
        }
      }
    }
    return friendsTokens;
  }

  // Assuming UserCredential is obtained after registration
  Future<void> storeUserData(String name, UserCredential user) async {
    try {
      final newUid = user.user!.uid;
      final newEmail = user.user!.email;

      await _firestore
          .collection('users')
          .doc(newUid)
          .set({'name': name, 'uid': newUid, 'email': newEmail, 'friends': []});
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  Future<void> saveFCMToken() async {
    String uid = await getStoredUid();
    if (uid != null) {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _firestore
            .collection('users')
            .doc(uid)
            .update({'fcmToken': fcmToken});
      }
    }
  }
}
