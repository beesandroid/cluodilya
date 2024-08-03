import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../student/Hostal.dart';
import '../student/feepayment.dart';
import 'hostal/hostalManagement.dart';
class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
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
              'Fee Payments',
              Icons.payment,
              Colors.orangeAccent,
              FeePaymentScreen(),
            ),
            _buildGridTile(
              context,
              'Transport',
              Icons.directions_bus,
              Colors.purpleAccent,
              null, // No navigation
              showToast: true, // Show toast message
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
                Get.snackbar('Error', 'Unable to navigate to the selected screen');
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
    final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayForStudentSearch';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'GrpCode': 'bees',
      'ColCode': '0001',
      // 'StudentId': '1642',
      'StudentId': '1642',
      'Flag': 'HostelStatus',
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
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
