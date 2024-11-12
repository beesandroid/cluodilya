import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentActivityScreen extends StatefulWidget {
  const StudentActivityScreen({super.key});

  @override
  _StudentActivityScreenState createState() => _StudentActivityScreenState();
}

class _StudentActivityScreenState extends State<StudentActivityScreen> {
  Map<String, dynamic>? activityDetail;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchStudentActivityDetails();
  }

  Future<void> fetchStudentActivityDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';

    final requestBody = {
      "GrpCode": "BeesDEV",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "ActivityId": "0",
      "ActivityName": "",
      "AchivementCompletedIn": "0",
      "JoinYear": "0",
      "Certificate": "0",
      "Remarks": "0",
      "UserId": adminUserId,
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
    };

    // Print request body to debug
    print("Request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentActivityDetailsDisplay'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("API Response: $data");
        if (data['studentActivityDetailsDisplayList'] != null &&
            data['studentActivityDetailsDisplayList'].isNotEmpty) {
          final personalDetails = data['studentActivityDetailsDisplayList'][0];
          setState(() {
            activityDetail = {
              "activityName": personalDetails["activityName"] ?? "N/A",
              "achivementCompletedIn":
                  personalDetails["achivementCompletedIn"] ?? "N/A",
              "joinYear": personalDetails["joinYear"] ?? "N/A",
              "certificate": personalDetails["certificate"] ?? "N/A",
              "remarks": personalDetails["remarks"] ?? "N/A",
              "achievement": personalDetails["achievement"] ?? "N/A",
              "event": personalDetails["event"] ?? "N/A",
              "awardGivenBy": personalDetails["awardGivenBy"] ?? "N/A",
            };
          });
        } else {
          setState(() {
            activityDetail = null;
            errorMessage = 'No Activity Details Available.';
          });
        }
      } else {
        // Handle non-200 responses
        setState(() {
          activityDetail = null;
          errorMessage = 'Failed to load student activity details.';
        });
        print('Failed to load student activity details');
      }
    } catch (e) {
      // Handle errors
      setState(() {
        activityDetail = null;
        errorMessage = 'Error fetching data: $e';
      });
      print('Error fetching student activity details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place a background gradient and content over it
      body: Stack(
        children: [
          // Background gradient with blue shades
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content with SafeArea
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Student Activity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : activityDetail != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildActivityCard(activityDetail!),
                            )
                          : Center(
                              child: Text(
                                errorMessage.isNotEmpty
                                    ? errorMessage
                                    : 'No Activity Details Available.',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> detail) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          // Glassmorphism effect
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      detail['activityName']?.toString() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details with icons
                  _buildDetailRow(
                      Icons.check_circle_outline,
                      'Achievement Completed In:',
                      detail['achivementCompletedIn']),
                  _buildDetailRow(Icons.calendar_today, 'Join Year:',
                      detail['joinYear']?.toString()),
                  _buildDetailRow(Icons.card_membership, 'Certificate:',
                      detail['certificate']?.toString()),
                  _buildDetailRow(
                      Icons.comment, 'Remarks:', detail['remarks']?.toString()),
                  _buildDetailRow(Icons.emoji_events, 'Achievement:',
                      detail['achievement']?.toString()),
                  _buildDetailRow(
                      Icons.event, 'Event:', detail['event']?.toString()),
                  _buildDetailRow(Icons.person, 'Award Given By:',
                      detail['awardGivenBy']?.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
