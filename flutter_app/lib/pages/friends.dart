import 'package:flutter/material.dart';
import 'package:flutter_app/screens/friends_screen.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<Friends> {
  // ... your existing code ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to FriendsScreen when the add button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsScreen()),
              );
            },
          ),
        ],
      ),
      // ... rest of your existing code ...
    );
  }
}
