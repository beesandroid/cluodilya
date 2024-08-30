import 'dart:convert';

import 'package:cloudilya/student/studentCertificates/studentsCertificate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Academics/Regulation.dart';
import 'Academics/courseEnrollment.dart';
import 'AttendaceRequest/Rquest management.dart';
import 'Attendence view/attendenceview.dart';
import 'HostalRegistration.dart';
import 'Myinfo/myInfo.dart';
import 'Transport/transportManagement.dart';
import 'calender/Calender.dart';
import 'feecard/feePermission.dart';
import 'feecard/feecard.dart';
import 'feepayment.dart';
import 'hostal/hostalManagement.dart';
import 'leaveRequest.dart';
import 'package:http/http.dart'as http;
class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logoutController();
            },
          ),
        ],
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(

        ),
        child: Column(
          children: [
            // Student Info Card
            _buildStudentInfoCard(),
            // Grid View for Navigation Items
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16.0),
                childAspectRatio: 1.2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                children: <Widget>[
                  _buildGridTile(
                    context,
                    'Fee Payments',

                    FeePaymentScreen(),
                  ),
                  _buildGridTile(
                    context,
                    'Attendance Request',

                    requestManagement(),
                  ),
                  _buildGridTile(
                    context,
                    'Leave Request',

                    LeaveRequest(),
                  ),
                  _buildGridTile(
                    context,
                    'Attendance View',

                    AttendanceView(),
                  ),
                  _buildGridTile(
                    context,
                    'FeeCard View',

                    FeeCard(),
                  ),
                  _buildGridTile(
                    context,
                    'Fee Permission View',

                    FeePermission(),
                  ),
                  _buildGridTile(
                    context,
                    'Student Certificate',

                    StudentCertificates(),
                  ),
                  _buildGridTile(
                    context,
                    'Regulation',

                    Regulation(),
                  ),


                  _buildGridTile(
                    context,
                    'Student Enrollment',

                    StudentEnrollment(),
                  ),
                  _buildGridTile(
                    context,
                    'Transport',

                    TransportManagement(),
                  ),
                  _buildGridTile(
                    context,
                    'My Info',

                    Myinfo(),
                  ), _buildGridTile(
                    context,
                    'Calender',

                    StudentTimeTableScreen(),
                  ),
                  _buildGridTile(
                    context,
                    'Hostal',

                    null
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/student_photo.jpg'),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('B.Tech, Computer Science'),
                Text('XYZ College, Section A'),
                Text('Hall Ticket: 123456789'),
                Text('Batch: 2020-2024'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(
      BuildContext context,
      String title,


      Widget? screen,
      ) {
    return GestureDetector(
      onTap: () async {
        if (title == 'Hostal') {
          await _handleHostalTap();
        } else {
          try {
            if (screen != null) {
              Get.to(() => screen);
            }
          } catch (e) {
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
                if (screen != null) {
                  Get.to(() => screen);
                }
              } catch (e) {
                print('Navigation error: $e');
                Get.snackbar('Error', 'Unable to navigate to the selected screen');
              }
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              // gradient: LinearGradient(
              //   colors: [Colors.white, Colors.blue[50]!],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 12.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.0,
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
      await prefs.clear();
      Get.offNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while logging out: ${e.toString()}',
      );
    }
  }
}
