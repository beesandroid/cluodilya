import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../student/Hostal.dart';
import '../student/feepayment.dart';
import 'Attendence.dart';
import 'LeaveApplication.dart';
// Import Fee Payments screen

class EmpDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          childAspectRatio: 1.1,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            _buildGridTile(
              context,
              'Attendance',
              Icons.check_circle,
              Colors.blueAccent,
              AttendanceScreen(),
            ),
            _buildGridTile(
              context,
              'Leave',
              Icons.attach_email,
              Colors.greenAccent,
              LeaveApplicationScreen(),
            ),



          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? screen, {
    bool showToast = false,
  }) {
    return GestureDetector(
      onTap: () {
        try {
          if (showToast) {
            Get.snackbar(
              'Info',
              'This feature is not available yet.',
              backgroundColor: Colors.black,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          } else if (screen != null) {
            Get.to(() => screen);
          }
        } catch (e) {
          // Log or handle navigation errors
          print('Navigation error: $e');
          Get.snackbar('Error', 'Unable to navigate to the selected screen');
        }
      },
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            try {
              if (showToast) {
                Get.snackbar(
                  'Info',
                  'This feature is not available yet.',
                  backgroundColor: Colors.black,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else if (screen != null) {
                Get.to(() => screen);
              }
            } catch (e) {
              // Log or handle navigation errors
              print('Navigation error: $e');
              Get.snackbar(
                  'Error', 'Unable to navigate to the selected screen');
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 56.0, color: color),
                SizedBox(height: 12.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
