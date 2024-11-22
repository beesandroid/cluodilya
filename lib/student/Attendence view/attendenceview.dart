import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String studId = prefs.getString('studId') ?? '';
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentAttendanceDisplay';
    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "Date": ""
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseData = json.decode(response.body);
        setState(() {
          data = responseData;
          print(data);
        });
      } else {
        // Handle error
        print('Failed to load data');
        setState(() {
          data = {}; // Set to empty map to trigger "No attendance" message
        });
      }
    } catch (e) {
      // Handle exception
      print('Error occurred: $e');
      setState(() {
        data = {}; // Set to empty map to trigger "No attendance" message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if data is available
    bool isDataAvailable = data != null &&
        data!.isNotEmpty &&
        (data!['subjectList']?.isNotEmpty ?? false ||
            data!['semesterLists']?.isNotEmpty ?? false ||
            data!['overAllList']?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: Colors.white,

      body: data == null
          ? Center(child: CircularProgressIndicator(color: Colors.grey[800]))
          : isDataAvailable
          ? _buildAttendanceView()
          : Center(
        child: Text(
          'No attendance available',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceView() {
    final subjectList = data?['subjectList'] ?? [];
    final semesterLists = data?['semesterLists'] ?? [];
    final overAllList = data?['overAllList'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Subjects'),
          SizedBox(height: 10),
          _buildSubjectGrid(subjectList),
          SizedBox(height: 20),
          _buildTitle('Semester Summary'),
          SizedBox(height: 10),
          ...semesterLists.map<Widget>((semester) {
            return _buildGlassCard(
              title: semester['sem'],
              totalClasses: semester['totalClasses'],
              totalAttended: semester['totalAttended'],
              percentage: semester['totalperc'],
            );
          }).toList(),
          SizedBox(height: 20),
          _buildTitle('Overall Summary'),
          SizedBox(height: 10),
          ...overAllList.map<Widget>((overall) {
            return _buildGlassCard(
              title: overall['sem'],
              totalClasses: overall['totalClasses'],
              totalAttended: overall['totalAttended'],
              percentage: overall['totalperc'],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid(List<dynamic> subjectList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: subjectList.length,
      itemBuilder: (context, index) {
        final subject = subjectList[index];
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 160,
          ),
          child: _buildGlassCard(
            title: subject['courseName'],
            totalClasses: subject['totalClasses'],
            totalAttended: subject['totalAttended'],
            percentage: subject['totalperc'],
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required String title,
    required int totalClasses,
    required int totalAttended,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total Classes: $totalClasses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Attended: $totalAttended',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.red.withOpacity(0.2),
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text(
              'Attendance: ${percentage.toStringAsFixed(2)}%',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
