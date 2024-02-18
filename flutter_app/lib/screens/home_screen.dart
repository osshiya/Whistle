// home_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// import 'package:flutter/foundation.dart';
// import 'package:familyjob/widgets.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter_app/features/tasks_history.dart';

import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/bleDB.dart' as BleDB;
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
  late BleDB.FirebaseHelper dbBleHelper;
  String? country;

  @override
  void initState() {
    super.initState();
    dbAuthHelper = AuthDB.FirebaseHelper();
    dbBleHelper = BleDB.FirebaseHelper();
    _getCurrentCountry();
  }

  Future<void> _getCurrentCountry() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        country = placemarks.first.country;
      });
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
                      String name = snapshot.data!['username'].toString();

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
                camelCase(name),
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

  String camelCase(String name) {
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
// Navigate to Tasks History Page
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
        future: dbBleHelper.getStoredEmergencies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // While data is loading
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          List<ListItemData> items = snapshot.data!.map((data) {
            // Assuming your Firebase document fields are 'title', 'subtitle', and 'time'
            String title = data['data'];
            // String subtitle = data['subtitle'] ?? '';
            // String time = data['time'] ?? '';
            return ListItemData(
              title: title,
              subtitle: "subtitle",
              time: "time",
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

  ListItemData({
    required this.title,
    required this.subtitle,
    required this.time
  });
}
