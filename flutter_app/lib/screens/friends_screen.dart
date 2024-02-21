import 'package:flutter/material.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/friendDB.dart' as FriendDB;

class FriendsScreen extends StatefulWidget {
  static const title = 'Friends';
  static const androidIcon = Icon(Icons.people);

  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late AuthDB.FirebaseHelper dbAuthHelper;
  late FriendDB.FirebaseHelper dbFriendHelper;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>>? friendsList = [];

  @override
  void initState() {
    super.initState();
    dbAuthHelper = AuthDB.FirebaseHelper();
    dbFriendHelper = FriendDB.FirebaseHelper();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    String? uid = await dbAuthHelper.getStoredUid();

    if (uid != null) {
      List<Map<String, dynamic>> friends = await dbFriendHelper.getFriends(uid);
      setState(() {
        friendsList = friends;
      });
    } else {
      print('Error: User email is null');
    }
  }

  Future<void> _deleteFriend(String friendEmail) async {
    String? myEmail = await dbAuthHelper.getStoredEmail();
    Map<String, dynamic>? friendData =
        await dbFriendHelper.getUserByEmail(friendEmail);
    if (friendData != null && friendData.isNotEmpty) {
      // Extract the 'friends' array from friendData
      List<Map<String, dynamic>> friendsList2 =
          List<Map<String, dynamic>>.from(friendData['friends'] ?? []);
      friendsList2.removeWhere((friend) => friend['email'] == myEmail);
      await dbFriendHelper.updateFriendsList(friendEmail, friendsList2!);
      print("Friends List: $friendsList");
    } else {
      print("No user found with email: $friendEmail");
    }
    friendsList!.removeWhere((friend) => friend['email'] == friendEmail);
    await dbFriendHelper.updateFriendsList(myEmail, friendsList!);
    await _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(children: [
              // Add Friend
              FutureBuilder<String>(
                future: dbAuthHelper.getStoredEmail(),
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
                                hintText: "Search Friend by Email",
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            String friendEmail = searchController.text.trim();

                            if (friendEmail.isNotEmpty) {
                              try {
                                String? email = userData;
                                Map<String, dynamic>? friendData =
                                    await dbFriendHelper
                                        .getUserByEmail(friendEmail);

                                if (friendData != null &&
                                    friendData.isNotEmpty) {
                                  await dbFriendHelper.addFriendByEmail(
                                      email!, friendEmail);
                                  await dbFriendHelper.addFriendByEmail(
                                      friendEmail, email);
                                  await _loadFriends();
                                } else {
                                  print(
                                      "No user found with email: $friendEmail");
                                }
                              } catch (e) {
                                print("Error adding friend: $e");
                              }
                            } else {
                              print("Please enter a friend's email");
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),

              // Friendlist
              Expanded(
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                          return FutureBuilder<String?>(
                            future: dbAuthHelper
                                .getUsername(friendsList![index]['uid']),
                            builder: (context, usernameSnapshot) {
                              if (usernameSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (usernameSnapshot.hasError) {
                                return Text('Error: ${usernameSnapshot.error}');
                              } else {
                                String? username = usernameSnapshot.data;
                                return Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(username ?? ''),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(username!,
                                            friendsList![index]['email']);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                  future: Future.value(null),
                ),
              ),
            ])));
  }

  Future<void> _showDeleteConfirmationDialog(
      String friendName, String friendEmail) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Friend'),
          content: Text('Are you sure you want to delete $friendName?'),
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
