import 'package:firebase_database/firebase_database.dart';

class RtdbHelper {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<void> addUserWithCoordinates(
      String uid, double latitude, double longitude) async {
    try {
      DatabaseReference userRef = _database.child('users/$uid');

      Map<String, dynamic> userData = {
        'latitude': latitude,
        'longitude': longitude,
      };

      await userRef.set(userData);
    } catch (error) {
      print('Error adding user with coordinates: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUsersWithCoordinates(List<String> userIds) async {
    List<Map<String, dynamic>> userList = [];
    try {
      for (String uid in userIds) {
        DatabaseReference userRef = _database.child('users/$uid');
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          Map<String, dynamic> userMap = {
            "uid": uid,
            "latitude": userData["latitude"],
            "longitude": userData["longitude"]
          };
          userList.add(userMap);
        }
      }
    } catch (error) {
      print('Error retrieving users with coordinates: $error');
    }
    return userList;
  }
}
