import 'package:blur_bottom_bar/blur_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:scaape/screens/explore_page.dart';
import 'package:scaape/utils/constants.dart';

import 'addScaape_screen.dart';
import 'chat_screen.dart';
import 'create_scaape.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'homeScreen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List pageList = [
    HomePageView(),
    ExplorePage(),
    CreateScaape(),
    NotificationScreen(),
    ProfileScreen(),
    // Container(color: Colors.red,),
    // Container(color: Colors.green,),
    // Container(color: Colors.yellow,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pageList[_selectedIndex],
          _selectedIndex != 2 ? BlurBottomView(
            filterX: 5,
            filterY: 5,
            opacity: 1,
            selectedItemColor: ScaapeTheme.kPinkColor,
            backgroundColor: Color(0xFF222831).withOpacity(0.1),
            // opacity: 0.3,
            unselectedItemColor: Colors.white,
            bottomNavigationBarItems: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('images/logo.png'),),
                label: 'Add Scape',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded),
                label: 'Notification',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              )
            ],
            currentIndex: _selectedIndex,
            onIndexChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ) : Container()
        ],
      ),
    );
  }
}
