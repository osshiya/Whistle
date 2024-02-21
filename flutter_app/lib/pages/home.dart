// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/map_screen.dart';
import 'package:flutter_app/screens/report_screen.dart';
import 'package:flutter_app/screens/friends_screen.dart';
import 'package:flutter_app/pages/report.dart';
import 'package:flutter_app/pages/bluetooth.dart';
import 'package:flutter_app/pages/settings.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({super.key, this.selectedIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  final _pageOptions = [
    const HomeScreen(),
    const FriendsScreen(),
    const MapScreen(),
    const ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

// ====================================================================================

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar;
    switch (_selectedIndex) {
      case 0:
        appBar = AppBar(
          actions: <Widget>[
            IconButton(
              icon: BLEPage.androidIcon,
              tooltip: BLEPage.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BLEPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: "Settings",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        );
        break;
      case 1:
        appBar = AppBar(
          title: const Text(FriendsScreen.title),
        );
        break;
      case 2:
        appBar = AppBar(
          title: const Text(MapScreen.title),
        );
        break;
      case 3:
        appBar = AppBar(
          title: const Text(ReportScreen.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              tooltip: "New Report",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateReportPage()),
                ).then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HomePage(
                        selectedIndex: 3,
                      ),
                    ),
                    (route) => false,
                  );
                });
              },
            ),
          ],
        );
        break;
      default:
        appBar = AppBar(title: const Text('Unknown Page'));
    }

    return Scaffold(
      appBar: appBar,
      body: _pageOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: HomeScreen.androidIcon,
            label: HomeScreen.title,
          ),
          BottomNavigationBarItem(
            icon: FriendsScreen.androidIcon,
            label: FriendsScreen.title,
          ),
          BottomNavigationBarItem(
            icon: MapScreen.androidIcon,
            label: MapScreen.title,
          ),
          BottomNavigationBarItem(
            icon: ReportScreen.androidIcon,
            label: ReportScreen.title,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2F7BEE),
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
