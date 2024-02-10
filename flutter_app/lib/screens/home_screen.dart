// home_screen.dart
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/db.dart';
import 'package:flutter_app/pages/settings.dart';

class HomeScreen extends StatefulWidget {
  static const title = 'Home';
  static const androidIcon = Icon(Icons.home);

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = FirebaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: dbHelper.getStoredUid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('UID not found');
            } else {
              String uid = snapshot.data!;

              // Use the obtained UID to fetch user data
              return FutureBuilder<Map<String, dynamic>?>(
                future: dbHelper.getUserData(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('User not found');
                  } else {
                    String username = snapshot.data!['username'].toString();
                    // String userbalance =
                    // snapshot.data!['userbalance'].toStringAsFixed(2);
                    // if (snapshot.data!['username'] == null ||
                    //     username == '') {
                    //   return const Text('Username not found');
                    // } else {
                    // Now, you have the username, use it in your UI
                    return TitleSection(
                      name: username,
                      balance: '0',
                    );
                    // }
                  }
                },
              );
            }
          },
        ),
        const ButtonSection(),
        const ActivitySection(name: "Recent Transactions"),
        const Lists(),
      ],
    );
  }

  // return Center(
  // child: Column(
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   children: [
  //     const Row(

  //     ),
  //     const Text(
  //       'Welcome to the Home Page!',
  //       style: TextStyle(fontSize: 20.0),
  //     ),
  //     const SizedBox(height: 16.0),
  //     ],
  //   ),
  // );
  // }
}

class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.balance,
  });

  final String name;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Welcome back, $name",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  "Your Balance",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 69, 69, 69),
                  ),
                ),
                Text(
                  balance,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          // #docregion Icon
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          // #enddocregion Icon
          const Text('41'),
        ],
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWithText(
            color: color,
            icon: Icons.call,
            label: 'CALL',
          ),
          ButtonWithText(
            color: color,
            icon: Icons.near_me,
            label: 'ROUTE',
          ),
          ButtonWithText(
            color: color,
            icon: Icons.share,
            label: 'SHARE',
          ),
        ],
      ),
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class ActivitySection extends StatefulWidget {
  const ActivitySection({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
// Navigate to Tasks History Page
  void _navigateToActivityHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                TextButton(
                  onPressed: _navigateToActivityHistory,
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Lists extends StatelessWidget {
  const Lists({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListSection(items: [
        ListItemData(title: 'a', subtitle: 'Subtitle A'),
        ListItemData(title: 'b', subtitle: 'Subtitle B'),
        ListItemData(title: 'c', subtitle: 'Subtitle C'),
        ListItemData(title: 'd', subtitle: 'Subtitle D'),
        ListItemData(title: 'e', subtitle: 'Subtitle E'),
      ]),
    );
  }
}

class ListSection extends StatelessWidget {
  const ListSection({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<ListItemData> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index].title),
          subtitle: Text(items[index].subtitle),
        );
      },
    );
  }
}

class ListItemData {
  final String title;
  final String subtitle;

  ListItemData({
    required this.title,
    required this.subtitle,
  });
}

// // #docregion ImageSection
// class ImageSection extends StatelessWidget {
//   const ImageSection({super.key, required this.image});

//   final String image;

//   @override
//   Widget build(BuildContext context) {
//     // #docregion Image-asset
//     return Image.asset(
//       image,
//       width: 600,
//       height: 240,
//       fit: BoxFit.cover,
//     );
//     // #enddocregion Image-asset
//   }
// }
// #enddocregion ImageSection
