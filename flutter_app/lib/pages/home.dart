// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/friends_screen.dart';
// import 'package:flutter/foundation.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/map_screen.dart';
import 'package:flutter_app/screens/report_screen.dart';

import 'package:flutter_app/pages/bluetooth.dart';
import 'package:flutter_app/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _pageOptions = [
    const HomeScreen(),
    const FriendsScreen(),
    const MapScreen(),
    const ReportScreen(),
    // const ProfileScreen()
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
          // title: const Text(HomeScreen.title),
          actions: <Widget>[
            IconButton(
              icon: BLEPage.androidIcon,
              tooltip: BLEPage.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BLEPage()),
                );
              },
            ),
            IconButton(
              icon: SettingsPage.androidIcon,
              tooltip: SettingsPage.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        );
        break;
      case 1:
        appBar = AppBar(
          title: const Text(FriendsScreen.title),
          actions: <Widget>[
            IconButton(
              icon: FriendsScreen.androidIcon,
              tooltip: FriendsScreen.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FriendsScreen()),
                );
              },
            ),
          ],
        );
        break;
      case 2:
        appBar = AppBar(
          title: const Text(MapScreen.title),
          actions: <Widget>[
            IconButton(
              icon: MapScreen.androidIcon,
              tooltip: MapScreen.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MapScreen()),
                );
              },
            ),
          ],
        );
        break;
      case 3:
        appBar = AppBar(
          title: const Text(ReportScreen.title),
          actions: <Widget>[
            IconButton(
              icon: ReportScreen.androidIcon,
              tooltip: ReportScreen.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportScreen()),
                );
              },
            ),
            IconButton(
              icon: ReportScreen.androidIcon,
              tooltip: ReportScreen.title,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportScreen()),
                );
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
          // BottomNavigationBarItem(
          //   icon: HomeScreen.androidIcon,
          //   label: HomeScreen.title,
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2F7BEE),
        onTap: _onItemTapped,
      ),
    );
  }
}
