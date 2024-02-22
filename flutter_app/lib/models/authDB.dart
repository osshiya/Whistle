import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/models/friendDB.dart' as Friend;

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
      // print('email: $storedEmail');
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

      if (data != null && data.containsKey('name')) {
        return data['name'].toString();
      } else {
        print('Username not found');
        return '';
      }
    } else {
      print('Snapshot is null or empty');
      return '';
    }
  }

  Future<String> getEmergencyNumber(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();

      if (data != null && data.containsKey('emergencyNumber')) {
        return data['emergencyNumber'].toString();
      } else {
        print('Number not found');
        return '';
      }
    } else {
      print('Snapshot is null or empty');
      return '';
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    if (uid.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();

        return data;
      } else {
        print('Snapshot is null or empty');
        return null;
      }
    } else {
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<String>> getFriendsFCMTokens() async {
    String uid = await getStoredUid();

    List<Map<String, dynamic>> friends =
        await Friend.FirebaseHelper().getFriends(uid);

    List<String> fcms = [];

    for (var friend in friends) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(friend['uid']).get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();

        if (data != null && data.containsKey('fcmToken')) {
          fcms.add(data['fcmToken'].toString());
        } else {
          print('fcmToken not found');
          fcms.add('');
        }
      } else {
        print('Snapshot does not exist');
        fcms.add('');
      }
    }

    return fcms;
  }

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
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'fcmToken': fcmToken});
    }
  }

  Future<void> updateUserData(newName, newEmergencyNumber) async {
    String uid = await getStoredUid();
    await _firestore
        .collection('users')
        .doc(uid)
        .update({'name': newName, 'emergencyNumber': newEmergencyNumber});
  }
}
