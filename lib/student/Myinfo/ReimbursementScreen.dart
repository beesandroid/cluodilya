import 'dart:convert';
import 'dart:ui'; // For blur effect
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  _ReimbursementScreenState createState() => _ReimbursementScreenState();
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  Map<String, dynamic>? reimbursementData;

  // State variables for handling loading and errors
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReimbursementDetails();
  }

  /// Fetches reimbursement details from the API
  Future<void> fetchReimbursementDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentReimbursementDetails');

    final requestBody = {
      "GrpCode": "BeesDEV",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "Id": 0,
      "StudentId": studId,
      "ApplicationNo": "",
      "ProceedingNumber": "",
      "ProceedingDate": "",
      "SourceName": "",
      "Year": 0,
      "UserId": adminUserId,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW"
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print("API Response: $responseBody");

        final detailsList = responseBody['studentReimbursementDetailsDisplayList'];

        if (detailsList != null && detailsList.isNotEmpty) {
          setState(() {
            reimbursementData = detailsList.first;
            errorMessage = '';
          });
        } else {
          setState(() {
            reimbursementData = null;
            errorMessage = 'No reimbursement details found.';
          });
        }
      } else {
        // Handle non-200 responses
        setState(() {
          reimbursementData = null;
          errorMessage = 'Failed to fetch data. Please try again later.';
        });
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or parsing errors
      setState(() {
        reimbursementData = null;
        errorMessage = 'An error occurred while fetching data.';
      });
      print('Error fetching reimbursement details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Builds the reimbursement details card
  Widget _buildDetailCard(
      String? applicationNo,
      String? proceedingNumber,
      String? proceedingDate,
      String? sourceName,
      int? year,
      String? commonDate,
      ) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          // Glassmorphism effect
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Reimbursement Details',
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
                      Icons.assignment, 'Application No:', applicationNo),
                  _buildDetailRow(Icons.receipt_long, 'Proceeding Number:',
                      proceedingNumber),
                  _buildDetailRow(
                      Icons.date_range, 'Proceeding Date:', proceedingDate),
                  _buildDetailRow(Icons.source, 'Source Name:', sourceName),
                  _buildDetailRow(
                      Icons.calendar_today, 'Year:', year?.toString()),
                  _buildDetailRow(Icons.today, 'Common Date:', commonDate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single detail row with an icon, label, and value
  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
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

  /// Builds the main content based on the state
  Widget _buildContent() {
    if (isLoading) {
      // Show loading indicator while fetching data
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      // Show error message or no data message
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (reimbursementData != null) {
      // Show reimbursement details if data is available
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildDetailCard(
          reimbursementData!['applicationNo'],
          reimbursementData!['proceedingNumber'],
          reimbursementData!['proceedingDate'],
          reimbursementData!['sourceName'],
          reimbursementData!['year'],
          reimbursementData!['commonDate'],
        ),
      );
    } else {
      // Fallback message
      return const Center(
        child: Text(
          'No Reimbursement Details Available.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place a background gradient and content over it
      body: Stack(
        children: [
          // Background gradient with updated colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
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
                        'Reimbursement Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded content based on state
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
