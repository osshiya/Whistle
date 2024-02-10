import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Future<Map<String, dynamic>?> getUserList(String uid) async {
  //   DocumentSnapshot<Map<String, dynamic>> snapshot =
  //       await _firestore.collection('users').doc(uid).get();

  //   if (snapshot.exists) {
  //     Map<String, dynamic>? data = snapshot.data();

  //     // if (data != null && data.containsKey('username')) {
  //     //   return data['username'].toString();
  //     // }
  //     return data;
  //   }
  //   return null;

  //   // Return an empty string if the username is not found or if the snapshot doesn't exist
  //   // return '';
  // }
  // Assume 'userId' is the ID of the user for whom you want to retrieve sub-users
  Future<List<Map<String, dynamic>>> getSubUsers(String uid) async {
    try {
      CollectionReference<Map<String, dynamic>> subUsersCollection =
          _firestore.collection('users/$uid/subUsers');

      QuerySnapshot<Map<String, dynamic>> subUsersSnapshot =
          await subUsersCollection.get();

      List<Map<String, dynamic>> subUsersData = subUsersSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data())
          .toList();

      return subUsersData;
    } catch (e) {
      print("Error retrieving sub-users: $e");
      return [];
    }
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
}
