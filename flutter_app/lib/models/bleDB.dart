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

  Future<String> getStoredReports(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('report').doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();

      if (data != null && data.containsKey('report')) {
        return data['report'].toString();
      }
    }

    // Return an empty string if is not found or if the snapshot doesn't exist
    return '';
  }

  Future<List<Map<String, dynamic>>?> getStoredEmergencies() async {
    String uid = await getStoredUid();
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users/$uid/emergency').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
        return doc.data();
      }).toList();
      print(data);
      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<String> getStoredBuzz(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('buzz').doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();

      if (data != null && data.containsKey('buzz')) {
        return data['buzz'].toString();
      }
    }

    // Return an empty string if is not found or if the snapshot doesn't exist
    return '';
  }

  Future<void> storeData(String uid, String type, String data) async {
    try {
      await _firestore
          .collection('users/$uid/$type')
          .doc()
          .set({'data': data});
    } catch (e) {
      print('Error storing data: $e');
    }
  }
}