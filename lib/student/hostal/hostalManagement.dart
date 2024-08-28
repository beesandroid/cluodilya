import 'package:flutter/material.dart';
import 'OutingRequestScreen.dart';
import 'RegisteredDetailsScreen.dart';
import 'RoomChangeScreen.dart';
import 'StudentComplaintsScreen.dart';

class HostelManagement extends StatefulWidget {
  const HostelManagement({super.key});

  @override
  State<HostelManagement> createState() => _HostelManagementState();
}

class _HostelManagementState extends State<HostelManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('Hostel Management'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            height: 60,
            color: Colors.blue[100],
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '    Registered Details    '),
                Tab(text: '    Room Change    '),
                Tab(text: '    Outing Request    '),
                Tab(text: '    Student Complaints    '),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => RegisteredDetailsScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => RoomChangeScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => OutingRequestScreen(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => StudentComplaintsScreen(),
              );
            },
          ),
        ],
      ),
    );
  }
}
