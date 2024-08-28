import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentActivityScreen extends StatelessWidget {
  const StudentActivityScreen({super.key});

  Future<Map<String, dynamic>> fetchStudentActivityDetails() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentActivityDetailsDisplay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "1239",
        "ActivityId": "0",
        "ActivityName": "",
        "AchivementCompletedIn": "0",
        "JoinYear": "0",
        "Certificate": "0",
        "Remarks": "0",
        "UserId": "1",
        "Achievement": "",
        "Event": "",
        "AwardGivenBy": "",
        "ChangeReason": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW",
        "StudentActivityDetailsDisplaytablevariable": [
          {"StudentId": "0", "File": ""}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['studentActivityDetailsDisplayList'][0];
    } else {
      throw Exception('Failed to load student activity details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: Text('Student Activity',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchStudentActivityDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          } else {
            final detail = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(color: Colors.white,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['activityName']?.toString() ?? 'N/A',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow('Achievement Completed In:', detail['achivementCompletedIn']?.toString() ?? 'N/A'),
                      _buildDetailRow('Join Year:', detail['joinYear']?.toString() ?? 'N/A'),
                      _buildDetailRow('Certificate:', detail['certificate']?.toString() ?? 'N/A'),
                      _buildDetailRow('Remarks:', detail['remarks']?.toString() ?? 'N/A'),
                      _buildDetailRow('Achievement:', detail['achievement']?.toString() ?? 'N/A'),
                      _buildDetailRow('Event:', detail['event']?.toString() ?? 'N/A'),
                      _buildDetailRow('Award Given By:', detail['awardGivenBy']?.toString() ?? 'N/A'),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
