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

  @override
  void initState() {
    super.initState();
    dbHelper = FirebaseHelper();
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
              // Replace with your logic to get the list of friends
              // For example, dbHelper.getFriends()
              // You can use a ListView.builder for efficiency
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<String>? friendsList = snapshot.data as List<String>?;

                  if (friendsList == null || friendsList.isEmpty) {
                    return Center(
                      child: Text('No friends yet'),
                    );
                  }

                  return ListView.builder(
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(friendsList[index]),
                          // Add more details or actions as needed
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
}



