// home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/bleDB.dart' as BleDB;
import 'package:flutter_app/models/rtDB.dart' as rtDB;

import 'package:flutter_app/pages/services.dart';
import 'package:flutter_app/pages/settings.dart';

class HomeScreen extends StatefulWidget {
  static const title = 'Home';
  static const androidIcon = Icon(Icons.home);

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthDB.FirebaseHelper dbAuthHelper;
  late rtDB.RtdbHelper rtdbHelper;
  late BleDB.FirebaseHelper dbBleHelper;
  String? country;

  @override
  void initState() {
    super.initState();
    rtdbHelper = rtDB.RtdbHelper();
    dbAuthHelper = AuthDB.FirebaseHelper();
    dbBleHelper = BleDB.FirebaseHelper();
    _getCurrentCountry();
  }
  
  Future<void> _getCurrentCountry() async {
    try {
      String? currentCountry = await LocationService.getCurrentCountry();
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          country = currentCountry;
        });
      }
    } catch (e) {
      print('Error getting current country: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      // Adjust the value as needed
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: dbAuthHelper.getStoredUid(),
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
                  future: dbAuthHelper.getUserData(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Text('User not found');
                    } else {
                      String name = snapshot.data!['name'].toString();

                      return TitleSection(
                        name: name,
                        country: country ?? 'Loading...',
                      );
                      // }
                    }
                  },
                );
              }
            },
          ),
          // const ButtonSection(),
          const ActivitySection(name: "Recent Activity"),
          Lists(dbBleHelper: dbBleHelper),
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.country,
  });

  final String name;
  final String country;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 80.0 / 2,
            backgroundColor: _randomColor(),
            child: Text(
              getInitials(name),
              style: const TextStyle(
                fontSize: 80.0 * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16), // Adjust spacing as needed
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pascalCase(name),
                style: const TextStyle(
                  fontSize: 80.0 * 0.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ButtonWithText(
                color: Color(0xFF838C98),
                icon: Icons.location_on,
                label: country,
              ),
            ],
          )
        ],
      ),
    );
  }

  String pascalCase(String name) {
    List<String> words = name.split(' ');
    String camelCaseString = '';
    for (int i = 0; i < words.length; i++) {
      camelCaseString +=
          '${words[i][0].toUpperCase()}${words[i].substring(1)} ';
    }
    return camelCaseString;
  }

  String getInitials(String name) {
    List<String> words = name.split(' ');
    String initials = '';
    for (String word in words) {
      if (word.isNotEmpty) {
        initials += word[0];
      }
    }
    return initials.toUpperCase();
  }

  Color _randomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(123 - 0 + 1) + 0,
      random.nextInt(123 - 0 + 1) + 0,
      random.nextInt(123 - 0 + 1) + 0,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
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
// Navigate to Activity History Page
  void _navigateToActivityHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      // onPressed: _navigateToActivityHistory,
      widget.name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class Lists extends StatelessWidget {
  final BleDB.FirebaseHelper dbBleHelper;

  const Lists({super.key, required this.dbBleHelper});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>?>(
        future: dbBleHelper.getStoredActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), // While data is loading
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const Text('No data available');
          }
          List<ListItemData> items = snapshot.data!.map((data) {
            // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
            String title = data['type'] ?? '';
            String subtitle = data['user'] ?? '';
            int? timestamp;
            if (data['timestamp'] is int) {
              timestamp = data['timestamp'];
            } else if (data['timestamp'] is String) {
              timestamp = int.tryParse(data['timestamp']);
            }

            DateTime? dateTime;
            String? formattedTime = "";
            if (timestamp != null) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

              // Format DateTime
              formattedTime = dateTime != null
                  ? DateFormat('MMM dd, hh:mm a').format(dateTime)
                  : '';
            }

            return ListItemData(
              title: title,
              subtitle: subtitle,
              time: formattedTime,
            );
          }).toList();
          return ListSection(items: items);
        },
      ),
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
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  items[index].title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                items[index].time,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey, // Adjust color as needed
                ),
              ),
            ],
          ),
          subtitle: Text(
            items[index].subtitle,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.grey, // Adjust color as needed
            ),
          ),
        );
      },
    );
  }
}

class ListItemData {
  final String title;
  final String subtitle;
  final String time;

  ListItemData(
      {required this.title, required this.subtitle, required this.time});
}
