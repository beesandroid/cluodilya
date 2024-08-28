import 'package:cloudilya/student/studentCertificates/studentsCertificate.dart';
import 'package:cloudilya/student/transportRegistration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../staff/Attendence.dart';
import '../staff/LeaveApplication.dart';
import '../student/HostalRegistration.dart';
import '../student/feepayment.dart';
import '../views/dashboard.dart';
import 'Academics/Regulation.dart';
import 'Academics/courseEnrollment.dart';
import 'AttendaceRequest/Rquest management.dart';
import 'Attendence view/attendenceview.dart';
import 'Myinfo/myInfo.dart';
import 'Transport/transportManagement.dart';
import 'hostal/hostalManagement.dart';
import 'leaveRequest.dart';

class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white60,


        title: Text('Student Dashboard',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logoutController();
            },
          ),
        ],
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
              'Fee Payments',
              Icons.payment,
              Colors.orangeAccent,
              FeePaymentScreen(),
            ),
            _buildGridTile(
              context,
              'Attendance Request',
              Icons.settings_applications,
              Colors.blue,
              requestManagement(),
            ),
            _buildGridTile(
              context,
              'Leave Request',
              Icons.volunteer_activism,
              Colors.green,
              LeaveRequest(),
            ),
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
            _buildGridTile(
              context,
              'dash',
              Icons.dashboard,
              Colors.red,
              DashboardScreen(),
            ),
            _buildGridTile(
              context,
              'Attendence View',
              Icons.class_rounded,
              Colors.red,
              AttendanceView(),
            ),
            _buildGridTile(
              context,
              'Student certificate ',
              Icons.checklist_rtl,
              Colors.red,
              StudentCertificates(),
            ),_buildGridTile(
              context,
              'Regulation ',
              Icons.report_gmailerrorred,
              Colors.red,
              Regulation(),
            ),
            _buildGridTile(
              context,
              'emp cert approval ',
              Icons.approval,
              Colors.green,
              AttendanceView(),
            ),
            _buildGridTile(
              context,
              'STUDENT LEAVE APPROVAL ',
              Icons.approval_rounded,
              Colors.black,
              AttendanceView(),
            ),   _buildGridTile(
              context,
              'Student  enrollment ',
              Icons.settings_applications_outlined,
              Colors.black,
              StudentEnrollment(),
            ),
            _buildGridTile(context, 'Transport', Icons.directions_bus,
                Colors.purpleAccent, TransportManagement()
                // TransportRegistrationScreen()// Show toast message
                ),
            _buildGridTile(context, 'myinfo', Icons.info_sharp, Colors.orange,
                Myinfo()
                // TransportRegistrationScreen()// Show toast message
                ),
            _buildGridTile(context, 'Transport', Icons.directions_bus,
                Colors.purpleAccent, TransportRegistrationScreen()
                // TransportRegistrationScreen()// Show toast message
                ),
            _buildGridTile(
              context,
              'Hostal',
              Icons.house,
              Colors.redAccent,
              null, // Will handle API call
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
      onTap: () async {
        if (title == 'Hostal') {
          await _handleHostalTap();
        } else {
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
        }
      },
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () async {
            if (title == 'Hostal') {
              await _handleHostalTap();
            } else {
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

  Future<void> _handleHostalTap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCode = prefs.getString('grpCode') ?? '';

    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';

    try {
      final url =
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayForStudentSearch';
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'GrpCode': grpCode,
        'ColCode': colCode,
        'StudentId': studId,
        'Flag': 'HostelStatus',
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print(responseData);
        final statusList = responseData['statusdisplayList'] as List<dynamic>;
        if (statusList.isNotEmpty) {
          final status = statusList[0]['status'] as int?;
          if (status == 0) {
            Get.to(() => HostelSelector());
          } else {
            Get.to(() => HostelManagement());
          }
        } else {
          Get.to(() => HostelManagement());
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch hostel status');
      }
    } catch (e) {
      print('API call error: $e');
      Get.snackbar('Error', 'Unable to fetch hostel status');
    }
  }
}

class _logoutController extends GetxController {
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs
          .clear(); // This clears all keys and values in SharedPreferences
      Get.offNamed('/login'); // Redirect to the login screen
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred while logging out: ${e.toString()}');
    }
  }
}
