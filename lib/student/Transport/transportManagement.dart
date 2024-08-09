import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'RegisteredDetails.dart';
import 'TransportStudentComplaints.dart';


class TransportManagement extends StatefulWidget {
  const TransportManagement({super.key});

  @override
  State<TransportManagement> createState() => _TransportManagementState();
}

class _TransportManagementState extends State<TransportManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('Transport Management'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            height: 60,
            color: Colors.blue[100],
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '    Registered Details    '),


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
                builder: (context) => TransportRegistrationDetailsScreen(),
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
