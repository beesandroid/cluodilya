import 'package:flutter/material.dart';

import 'Address.dart';
import 'PersonalActivity.dart';
import 'Personaldetails.dart';
import 'ReimbursementScreen.dart';

class Myinfo extends StatefulWidget {
  const Myinfo({super.key});

  @override
  State<Myinfo> createState() => _MyinfoState();
}

class _MyinfoState extends State<Myinfo> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Personaldetails(),
    const AddressDetailsScreen(),
    const StudentActivityScreen(),
    const ReimbursementScreen(),
    const MentorDetailsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Personal',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Address',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: 'Activity',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money),
                    label: 'Reimbursement',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Mentor',
                  ),
                ],
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}







class MentorDetailsScreen extends StatelessWidget {
  const MentorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Mentor Details Screen', style: TextStyle(fontSize: 20, color: Colors.black)),
    );
  }
}
