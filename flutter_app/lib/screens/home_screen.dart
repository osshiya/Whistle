// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/models/authDB.dart' as AuthDB;
import 'package:flutter_app/models/bleDB.dart' as BleDB;
import 'package:flutter_app/models/rtDB.dart' as rtDB;
import 'package:flutter_app/pages/emergency.dart';
import 'package:flutter_app/pages/report.dart';
import 'package:flutter_app/pages/services.dart';
import 'package:flutter_app/pages/settings.dart';
import 'package:flutter_app/utils/formatter.dart';

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
    dbAuthHelper.saveFCMToken();
  }

  Future<void> _getCurrentCountry() async {
    try {
      String? currentCountry = await LocationService.getCurrentCountry();
      if (mounted) {
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
                    }
                  },
                );
              }
            },
          ),
          const ActivitySection(name: "Recent Activity"),
          Lists(dbAuthHelper: dbAuthHelper, dbBleHelper: dbBleHelper),
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
            backgroundColor: randomColor(),
            child: Text(
              getInitials(name),
              style: const TextStyle(
                fontSize: 80.0 * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 16),
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
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.name,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class Lists extends StatelessWidget {
  final AuthDB.FirebaseHelper dbAuthHelper;
  final BleDB.FirebaseHelper dbBleHelper;

  const Lists(
      {super.key, required this.dbAuthHelper, required this.dbBleHelper});

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

        // Use Future.wait to await the list of futures
        return FutureBuilder<List<ListItemData>>(
          future: Future.wait(snapshot.data!.map((data) async {
            String title = data['title'] ?? data['type'] ?? '';
            String uid = data['user'] ?? '';
            String username =
                await dbAuthHelper.getUsername(data['user']) ?? '';
            int? timestamp;
            if (data['timestamp'] is int) {
              timestamp = data['timestamp'];
            } else if (data['timestamp'] is String) {
              timestamp = int.tryParse(data['timestamp']);
            }

            String? formattedTime = formatTimestamp(timestamp!);

            return ListItemData(
                id: data['id'],
                uid: uid,
                username: username,
                title: title,
                time: formattedTime,
                type: data['type']);
          }).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Text('No data available');
            }

            // Return your ListSection widget with the list of ListItemData
            return ListSection(items: snapshot.data!);
          },
        );
      },
    ));
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
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          subtitle: Text(
            items[index].username,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          onTap: () {
            if (items[index].type == "Report") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewReportPage(
                          id: items[index].id,
                          uid: items[index].uid,
                        )),
              ).then((_) {});
            } else if (items[index].type == "Emergency") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyPage(
                        id: items[index].id, uid: items[index].uid)),
              ).then((_) {});
            }
          },
        );
      },
    );
  }
}

class ListItemData {
  final String id;
  final String uid;
  final String username;
  final String title;
  final String time;
  final String type;

  ListItemData(
      {required this.id,
      required this.uid,
      required this.username,
      required this.title,
      required this.time,
      required this.type});
}
