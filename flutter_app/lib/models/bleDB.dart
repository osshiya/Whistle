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

  // Future<String> getStoredReport(String uid) async {
  //   DocumentSnapshot<Map<String, dynamic>> snapshot =
  //   await _firestore.collection('report').doc(uid).get();
  //
  //   if (snapshot.exists) {
  //     Map<String, dynamic>? data = snapshot.data();
  //
  //     if (data != null && data.containsKey('report')) {
  //       return data['report'].toString();
  //     }
  //   }
  //
  //   // Return an empty string if is not found or if the snapshot doesn't exist
  //   return '';
  // }

  Future<List<Map<String, dynamic>>?> getStoredActivities() async {
    String uid = await getStoredUid();
    if (uid != null) {
      // Create an empty list to store combined data
      List<Map<String, dynamic>> combinedData = [];

      // Retrieve reports
      List<Map<String, dynamic>>? reports = await getStoredReports();
      if (reports != null) {
        combinedData.addAll(reports);
      }

      // Retrieve emergencies
      List<Map<String, dynamic>>? emergencies = await getStoredEmergencies();
      if (emergencies != null) {
        combinedData.addAll(emergencies);
      }

      // Retrieve buzz
      List<Map<String, dynamic>>? buzz = await getStoredBuzz();
      if (buzz != null) {
        combinedData.addAll(buzz);
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

  Future<Map<String, dynamic>?> getStoredReport(String id) async {
    String uid = await getStoredUid();
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

  Future<List<Map<String, dynamic>>?> getStoredReports() async {
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

  Future<List<Map<String, dynamic>>?> getStoredEmergencies() async {
    String uid = await getStoredUid();
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/emergency').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
        return doc.data();
      }).toList();

      return data;
    } else {
      // Handle the case where uid is null or empty
      print('UID is null or empty');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getStoredBuzz() async {
    String uid = await getStoredUid();
    if (uid != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users/$uid/buzz').get();

      List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
        // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
        return doc.data();
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
