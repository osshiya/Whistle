import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/utils/notification_handler.dart';
import 'package:flutter_app/models/friendDB.dart' as Friend;

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

  Future<List<Map<String, dynamic>>?> getMyStoredReports() async {
    String uid = await getStoredUid();
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/report').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        String docId = doc.id;

        Map<String, dynamic> docData = doc.data();

        docData['id'] = docId;

        return docData;
      }).toList();

      data.sort((a, b) {
        // Parse timestamps, handling both int and String types
        int timestampA = a['timestamp'] is int
            ? a['timestamp']
            : int.tryParse(a['timestamp']) ?? 0;
        int timestampB = b['timestamp'] is int
            ? b['timestamp']
            : int.tryParse(b['timestamp']) ?? 0;

        // Compare timestamps and sort in descending order (latest first)
        return timestampB.compareTo(timestampA);
      });

      // Return the combined data
      return data;

      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStoredActivities() async {
    String uid = await getStoredUid();

    if (uid != null) {
      List<Map<String, dynamic>> friends =
          await Friend.FirebaseHelper().getFriends(uid);

      friends.add({'uid': uid});

      print(friends[0]['uid']);
      // Create an empty list to store combined data
      List<Map<String, dynamic>> combinedData = [];

      for (Map<String, dynamic> friend in friends) {
        // Retrieve reports
        List<Map<String, dynamic>>? reports =
            await getStoredReports(friend['uid']);
        if (reports != null) {
          combinedData.addAll(reports);
        }

        // Retrieve emergencies
        List<Map<String, dynamic>>? emergencies =
            await getStoredEmergencies(friend['uid']);
        if (emergencies != null) {
          combinedData.addAll(emergencies);
        }

        // Retrieve buzz
        List<Map<String, dynamic>>? buzz = await getStoredBuzz(friend['uid']);
        if (buzz != null) {
          combinedData.addAll(buzz);
        }
      }

// Sort the combined data by date
      combinedData.sort((a, b) {
        // Parse timestamps, handling both int and String types
        int timestampA = a['timestamp'] is int
            ? a['timestamp']
            : int.tryParse(a['timestamp']) ?? 0;
        int timestampB = b['timestamp'] is int
            ? b['timestamp']
            : int.tryParse(b['timestamp']) ?? 0;

        // Compare timestamps and sort in descending order (latest first)
        return timestampB.compareTo(timestampA);
      });

      // Return the combined data
      return combinedData;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStoredReport(String uid, String id) async {
    if (uid != null) {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('users/$uid/report').doc(id).get();

      if (docSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = docSnapshot.data()!;
        // Add the document ID to the data
        data['id'] = id;
        return data;
      } else {
        // Document with the given ID does not exist
        print('Document with ID $id does not exist');
        return null;
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStoredEmergency(String uid, String id) async {
    if (uid != null) {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('users/$uid/emergency').doc(id).get();

      if (docSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = docSnapshot.data()!;
        // Add the document ID to the data
        data['id'] = id;
        return data;
      } else {
        // Document with the given ID does not exist
        print('Document with ID $id does not exist');
        return null;
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStoredReports(String uid) async {
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/report').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        String docId = doc.id;

        Map<String, dynamic> docData = doc.data();

        docData['id'] = docId;

        return docData;
      }).toList();

      data.sort((a, b) {
        // Parse timestamps, handling both int and String types
        int timestampA = a['timestamp'] is int
            ? a['timestamp']
            : int.tryParse(a['timestamp']) ?? 0;
        int timestampB = b['timestamp'] is int
            ? b['timestamp']
            : int.tryParse(b['timestamp']) ?? 0;

        // Compare timestamps and sort in descending order (latest first)
        return timestampB.compareTo(timestampA);
      });

      // Return the combined data
      return data;

      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStoredEmergencies(String uid) async {
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/emergency').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        String docId = doc.id;

        Map<String, dynamic> docData = doc.data();

        docData['id'] = docId;

        return docData;
      }).toList();

      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStoredBuzz(String uid) async {
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/buzz').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        String docId = doc.id;

        Map<String, dynamic> docData = doc.data();

        docData['id'] = docId;

        return docData;
      }).toList();

      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<void> storeData(String uid, String type, int timestamp) async {
    try {
      await _firestore.collection('users/$uid/$type').doc().set({
        'type': type[0].toUpperCase() + type.substring(1),
        'user': uid,
        'timestamp': timestamp
      });
      sendPushMessage(uid, type);
    } catch (e) {
      print('Error storing data: $e');
    }
  }

  Future<void> createData(String type, String title, String desc) async {
    String uid = await getStoredUid();
    if (uid != null) {
      try {
        await _firestore.collection('users/$uid/$type').doc().set({
          'type': type[0].toUpperCase() + type.substring(1),
          'user': uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toInt(),
          'title': title,
          'desc': desc
        });
      } catch (e) {
        print('Error updating data: $e');
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<void> updateData(
      String id, String type, String title, String desc) async {
    String uid = await getStoredUid();
    if (uid != null) {
      try {
        await _firestore
            .collection('users/$uid/$type')
            .doc(id)
            .update({'title': title, 'desc': desc});
      } catch (e) {
        print('Error updating data: $e');
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<void> deleteData(String id, String type) async {
    String uid = await getStoredUid();
    if (uid != null) {
      try {
        await _firestore.collection('users/$uid/$type').doc(id).delete();
      } catch (e) {
        print('Error updating data: $e');
      }
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }
}
