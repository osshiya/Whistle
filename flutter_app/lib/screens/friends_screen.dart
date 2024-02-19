import 'package:flutter/material.dart';
import 'package:flutter_app/models/authDB.dart';

class FriendsScreen extends StatefulWidget {
  static const title = 'Friends';
  static const androidIcon = Icon(Icons.people);

  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FirebaseHelper dbHelper;
  TextEditingController searchController = TextEditingController();
  List<String>? friendsList = [];


  @override
  void initState() {
    super.initState();
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
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for friends...',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // Implement friend adding logic here
                },
              ),
            ],
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
              future: null, // Replace with your actual future function to get friends
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

