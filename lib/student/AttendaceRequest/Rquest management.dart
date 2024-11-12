import 'package:flutter/material.dart';

import 'attendance.dart';
import 'class.dart';

class requestManagement extends StatefulWidget {
  const requestManagement({super.key});

  @override
  State<requestManagement> createState() => _requestManagementState();
}

class _requestManagementState extends State<requestManagement>
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
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Request Management',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            height: 60,
            color: Colors.blue[100],
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '       Class Request    '),
                Tab(text: '    Attendance Request    '),

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
                builder: (context) => ClassRequest(),
              );
            },
          ),
          Navigator(
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                builder: (context) => AttendanceRequest(),
              );
            },
          ),

        ],
      ),
    );
  }
}