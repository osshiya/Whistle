import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class FirebaseHelper {
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (email != null && email.isNotEmpty) {
      // Query the collection for the user with the specified email
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming that email is unique, so there should be only one result

        Map<String, dynamic>? data = querySnapshot.docs.first.data();

        return data;
      } else {
        // Handle the case where no user is found with the specified email
        print('No user found with email: $email');
        return null;
      }
    } else {
      // Handle the case where email is null or empty
      print('Email is null or empty');
      return null;
    }
  }

  Future<void> addFriendByEmail(String email, String newFriendEmail) async {
    try {
      // Retrieve the user data based on email
      Map<String, dynamic>? userData = await getUserByEmail(email);

      if (userData != null && userData.containsKey('uid')) {
        Map<String, dynamic>? newFriendData = await getUserByEmail(newFriendEmail);

        if (newFriendData != null && newFriendData.containsKey('uid')) {
          // Extract the current friends list from the user data
          List<Map<String, dynamic>> currentFriends =
          List<Map<String, dynamic>>.from(userData['friends'] ?? []);

          Map<String, String> newFriend = { 'uid': newFriendData['uid'], 'email': newFriendEmail };

          // Append the new friend email to the list
          currentFriends.add(newFriend);

          // Update the 'friends' field in the user document based on email
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
      // Get the user data along with UID
      Map<String, dynamic>? userData = await getUserByEmail(email);

      if (userData != null) {
        // Extract UID from user data
        String uid = userData['uid'];

        // Update the 'friends' field in the user document based on UID
        await _firestore.collection('users').doc(uid).update({
          'friends': updatedFriends,
        });

        print('Friend list updated successfully');
      } else {
        // No user found with the specified email
        print("No user found with email: $email");
      }
    } catch (e) {
      // Handle any errors that may occur during the process
      print('Error updating friend list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFriends(String uid) async {
    try {
      // Fetch user document based on UID
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(uid).get();

      // Check if user document exists
      if (userDoc.exists) {
        // Extract and return the friends list
        List<Map<String, dynamic>> friends = List<Map<String, dynamic>>.from(userDoc['friends'] ?? []);

        // // Extract email addresses from the list of friends
        // List<String> friendEmails = friends.map<String>((friend) => friend['email'] as String).toList();

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