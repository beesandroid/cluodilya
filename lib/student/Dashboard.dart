import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'Academics/Regulation.dart';
import 'Academics/courseEnrollment.dart';
import 'AttendaceRequest/Rquest management.dart';
import 'HostalRegistration.dart';
import 'Transport/transportManagement.dart';
import 'Transport/transportRegistration.dart';
import 'feecard/feePermission.dart';
import 'feepayment.dart';
import 'hostal/hostalManagement.dart';
import 'leaveRequest.dart';
import 'studentCertificates/studentsCertificate.dart';
class DashboardHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              _buildStudentInfoCard(),
              Container(
                height: MediaQuery.of(context).size.height *
                    0.6, // Adjust the height as needed
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16.0),
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  // Ensures GridView does not take more space than needed
                  physics: NeverScrollableScrollPhysics(),
                  // Prevents GridView from scrolling independently
                  children: <Widget>[
                    _buildGridTile(
                      context,
                      'Fee Payments',
                      FontAwesomeIcons.ccAmazonPay,
                      FeePaymentScreen(),
                    ),
                    _buildGridTile(
                      context,
                      'Requests ',
                      FontAwesomeIcons.receipt,
                      requestManagement(),
                    ),
                    _buildGridTile(
                      context,
                      'Leave Req',
                      Icons.approval,
                      LeaveRequest(),
                    ),
                    _buildGridTile(
                      context,
                      'Transport',
                      Icons.directions_bus,
                      TransportManagement(),
                    ),
                    _buildGridTile(
                      context,
                      'Certificates',
                      FontAwesomeIcons.certificate, // Icon from FontAwesome
                      StudentCertificates(), // Navigates to StudentCertificates screen
                    ),
                    _buildGridTile(
                      context,
                      'Regulation',
                      FontAwesomeIcons.addressBook,
                      Regulation(),
                    ),
                    _buildGridTile(
                      context,
                      'Student Enrol',
                      FontAwesomeIcons.registered,
                      StudentEnrollment(),
                    ),
                    _buildGridTile(
                      context,
                      'Hostel Reg',
                      FontAwesomeIcons.hotel,
                      HostelSelector(),
                    ),
                    _buildGridTile(
                      context,
                      'Hostel ',
                      Icons.hotel,
                      HostelManagement(),
                    ),
                    _buildGridTile(
                      context,
                      'Permission',
                      FontAwesomeIcons.personMilitaryPointing,
                      FeePermission(),
                    ),
                    _buildGridTile(
                      context,
                      'Transport',
                      FontAwesomeIcons.bus,
                      TransportRegistrationScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Padding(
      padding: const EdgeInsets.only(top:28.0),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 440.0,
              margin: EdgeInsets.symmetric(vertical: 40.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'R Jagadeesh',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],

                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Bio Technology',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'GIET College, Section A',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Hall Ticket: 123456789',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Batch: 2018 - PRESENT',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -25,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue[50]!,
                        Colors.blueAccent.withOpacity(0.7),
                        Colors.deepPurpleAccent.withOpacity(0.5),
                      ],
                      center: Alignment.center,
                      radius: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profilepic.jpeg',
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildGridTile(BuildContext context, String title, IconData icon,
      Widget? screen // Accept the screen as a positional parameter
      ) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Get.to(() => screen);
        }
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[50],
              child: Icon(
                icon, // Use the provided IconData here
                size: 30,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10.0),
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
    );
  }
}
