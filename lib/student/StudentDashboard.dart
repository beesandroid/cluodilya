import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'Academics/busmap.dart';
import 'Attendence view/attendenceview.dart';
import 'CustomDrawer/CustomDrawer.dart';
import 'Dashboard.dart';
import 'NoticeBoard.dart';
import 'Notification/Notification.dart';
import 'calender/Calender.dart';
import 'package:ionicons/ionicons.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late PersistentTabController _controller;

  _StudentDashboardState()
      : _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      Noticeboard(),

      ViewLocationsPage(),
      AttendanceView(),
      DashboardHomePage(),

      StudentTimeTableScreen(), // Updated to match the navigation items
    ];
  }

  final List<String> _titles = [
    'NoticeBoard',

    'Bus Tracking',
    'Attendance',
    'Dashboard',
    'Time Table',
    // Added the missing title here
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Ionicons.archive),
        title: ("NoticeBoard"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Ionicons.bus),
        title: ("Bus Tracking"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.feed),
        title: ("Attendance"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.home),
        title: ("Home"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.calendar),
        title: ("Time Table"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _titles[_controller.index],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Noti()));
            },
          ),
        ],
      ),
      drawer: CustomDrawer(), // Use your custom drawer here
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        onItemSelected: (index) {
          setState(() {
            _controller.index = index; // Update the controller index
          });
        },
        navBarStyle: NavBarStyle.style9, // Ensure this style is supported
      ),
    );
  }
}
