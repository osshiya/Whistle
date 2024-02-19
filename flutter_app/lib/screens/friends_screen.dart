import 'package:flutter/material.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;

import '../models/authDB.dart';
import '../models/authDB.dart';
import '../models/authDB.dart';

class FriendsScreen extends StatefulWidget {
  static const title = 'Friends';
  static const androidIcon = Icon(Icons.people);

  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FirebaseHelper dbHelper;
  late AuthDB.FirebaseHelper dbAuthHelper;
  TextEditingController searchController = TextEditingController();
  List<String>? friendsList = [];

  @override
  void initState() {
    super.initState();
    dbAuthHelper = AuthDB.FirebaseHelper();
    dbHelper = FirebaseHelper();
    _loadFriends(); // Load friends when the widget is initialized
  }

  Future<void> _loadFriends() async {
    // Replace this with your logic to get the list of friends
    // For example, dbHelper.getFriends()
    friendsList = ["Tom", "John", "Mary"];
    setState(() {}); // Trigger a rebuild to update the UI
  }

  Future<void> _deleteFriend(String friendEmail) async {
    // Implement your delete logic here
    // For example, dbHelper.deleteFriend(friendEmail);

    // Update the UI after deletion
    setState(() {
      friendsList!.remove(friendEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<String>(
            future: dbAuthHelper.getStoredEmail(), // Replace 'uid' with your actual UID
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                String? userData = snapshot.data;

                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Write friend's email",
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        // Get the email from the text field
                        String friendEmail = searchController.text.trim();

                        if (friendEmail.isNotEmpty) {
                          try {
                            // Access the email from the user data snapshot
                            String? email = userData;
                            print("My email: $email");

                            // Call the getUserByEmail method to get the user object
                            Map<String, dynamic>? friendData = await dbHelper.getUserByEmail(friendEmail);

                            if (friendData != null && friendData.isNotEmpty) {
                              // Friend found, you can now use friendData
                              print("Friend found: $friendData");
                              print("Your email: $email");
                              dbHelper.addFriendByEmail(email!, friendEmail);
                              dbHelper.addFriendByEmail(friendEmail, email);
                              // Implement the logic to add the friend to your friend list
                              // This might involve updating Firestore or your local state
                            } else {
                              // No user found with the specified email
                              print("No user found with email: $friendEmail");
                            }
                          } catch (e) {
                            // Handle any errors that may occur during the process
                            print("Error adding friend: $e");
                          }
                        } else {
                          // Handle the case where the email is empty
                          print("Please enter a friend's email");
                        }
                      },
                    ),
                  ],
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (friendsList == null || friendsList!.isEmpty) {
                    return Center(
                      child: Text('No friends yet'),
                    );
                  }

                  return ListView.builder(
                    itemCount: friendsList!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(friendsList![index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmationDialog(friendsList![index]);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              future: Future.value(null), // Replace with your actual future function to get friends
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String friendEmail) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Friend'),
          content: Text('Are you sure you want to delete $friendEmail?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFriend(friendEmail);
                Navigator.pop(context); // Close the dialog after deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
