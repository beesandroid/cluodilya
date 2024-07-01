import 'package:flutter/material.dart';

import '../main.dart';

// Define separate screen widgets
class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class SearchScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Screen', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class ProfileScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Screen', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class NotificationsScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Notifications Screen', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class MessagesScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Messages', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('menu', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class timetable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('timetable', style: TextStyle(fontSize: 24, color: Colors.black)),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  // List of pages
  final List<Widget> _pages = [
    HomeScreenContent(),
    SearchScreenContent(),
    ProfileScreenContent(),
    NotificationsScreenContent(),
    MessagesScreenContent(),
    menu(),
    timetable(),
  ];

  final List<String> _pageTitles = [
    'Home',
    'Search',
    'Profile',
    'Notifications',
    'Messages',
    'menu',
    'attendence'
  ];

  void _onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void _onTap(int index) {
    setState(() {
      _pageIndex = index;
      _pageController.jumpToPage(index); // Jump to the selected page without animation
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: (){}, // Call the logout method
        ),
        title: Text(_pageTitles[_pageIndex], style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Container(
            height: 66, // Ensure this height fits within the screen constraints
            decoration: BoxDecoration(
              color: Color(0xFF003d85), // Background color of BottomNavigationBar
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              child: BottomNavigationBar(
                currentIndex: _pageIndex,
                backgroundColor: Colors.transparent, // Transparent to show container color
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white54,
                showSelectedLabels: false, // Hide the labels for selected items
                showUnselectedLabels: false, // Hide the labels for unselected items
                onTap: _onTap,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '', // Empty label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: '', // Empty label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '', // Empty label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notification_add),
                    label: '', // Empty label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.message),
                    label: '', // Empty label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: '', // Empty label
                  ),BottomNavigationBarItem(
                    icon: Icon(Icons.access_time),
                    label: '', // Empty label
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
