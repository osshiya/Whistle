import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class FirebaseHelper {
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (email.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? data = querySnapshot.docs.first.data();

        return data;
      } else {
        print('No user found with email: $email');
        return null;
      }
    } else {
      print('Email is null or empty');
      return null;
    }
  }

  Future<void> addFriendByEmail(String email, String newFriendEmail) async {
    try {
      Map<String, dynamic>? userData = await getUserByEmail(email);

      if (userData != null && userData.containsKey('uid')) {
        Map<String, dynamic>? newFriendData =
            await getUserByEmail(newFriendEmail);

        if (newFriendData != null && newFriendData.containsKey('uid')) {
          List<Map<String, dynamic>> currentFriends =
              List<Map<String, dynamic>>.from(userData['friends'] ?? []);

          Map<String, String> newFriend = {
            'uid': newFriendData['uid'],
            'email': newFriendEmail
          };

          currentFriends.add(newFriend);

          await _firestore
              .collection('users')
              .doc(userData['uid'])
              .update({'friends': currentFriends});

          print('Friend added successfully');
        } else {
          print('New friend not found with email: $newFriendEmail');
        }
      } else {
        print('User not found with email: $email');
      }
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> updateFriendsList(
      String email, List<Map<String, dynamic>> updatedFriends) async {
    try {
      Map<String, dynamic>? userData = await getUserByEmail(email);

      if (userData != null) {
        String uid = userData['uid'];

        await _firestore.collection('users').doc(uid).update({
          'friends': updatedFriends,
        });

        print('Friend list updated successfully');
      } else {
        print("No user found with email: $email");
      }
    } catch (e) {
      print('Error updating friend list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFriends(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> friends =
            List<Map<String, dynamic>>.from(userDoc['friends'] ?? []);
        return friends;
      } else {
        print('User not found with UID: $uid');
        return [];
      }
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }
}
