import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Personaldetails extends StatefulWidget {
  const Personaldetails({super.key});

  @override
  State<Personaldetails> createState() => _PersonaldetailsState();
}

class _PersonaldetailsState extends State<Personaldetails> {
  Map<String, dynamic> personalDetails = {};
  bool isLoading = true;
  bool isEditing = false; // Flag to toggle between view and edit mode

  // Controllers for editable fields
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    fetchPersonalDetails();
  }

  Future<void> fetchPersonalDetails() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentPersonalDetalisDisplay');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "1645",
        "HallTicketNo": "22H41A0311",
        "Name": "",
        "Gender": "0",
        "DateOfBirth": "",
        "FatherName": "",
        "FatherOccupation": "",
        "MotherName": "",
        "MotherOccupation": "",
        "MotherTongue": "0",
        "Nationality": "0",
        "Religion": "0",
        "CasteCategory": "0",
        "Caste": "0",
        "BloodGroupId": "0",
        "Mobile": "",
        "StudentEmail": "",
        "StudMobile": "",
        "Mole1": "",
        "Mole2": "",
        "RationCardNo": "",
        "PassPortNo": "",
        "PANCardNo": "",
        "BankAccountNo": "",
        "VoterId": "",
        "Bank": "0",
        "BankBranch": "",
        "IFSCCode": "",
        "DrivingLicenceNo": "",
        "AadharNo": "",
        "FatherAadharNo": "",
        "MotherAadharNo": "",
        "NationalIdentityNo": "",
        "ChangeReason": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final details = data['studentPersonalDetalisDisplayList'].isNotEmpty
          ? data['studentPersonalDetalisDisplayList'][0]
          : {};

      setState(() {
        personalDetails = details;

        // Initialize controllers with fetched data
        controllers.clear();
        personalDetails.forEach((key, value) {
          controllers[key] =
              TextEditingController(text: value?.toString() ?? '');
        });

        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch personal details'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> updatePersonalDetails() async {
    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentPersonalDetalisDisplay');

    // Prepare the request body
    final requestBody = {
      ...personalDetails,
      "Flag": "OVERWRITE",
      // Include updated values from controllers
      ...controllers.map((key, controller) => MapEntry(key, controller.text)),
    };

    // Print the request body for debugging
    print('Request Body: ${json.encode(requestBody)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final message = data['message'] ?? 'An unknown error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isEditing = false; // Switch back to view mode after saving
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update personal details'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  void dispose() {
    // Dispose controllers
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: Text(
          'Personal Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 118.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isEditing) {
                          // Save changes and switch back to view mode
                          updatePersonalDetails();
                        } else {
                          // Switch to edit mode
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Save Changes' : 'Modify',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ...personalDetails.entries.map((entry) {
                  // Skip unwanted entries
                  if (entry.key != 'studentPersonalDetalisDisplayList') {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${entry.key}:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: isEditing
                                ? TextField(
                              controller: controllers[entry.key],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8),
                              ),
                              maxLines: entry.key == 'address' ? 3 : 1,
                            )
                                : Text(
                              '${entry.value ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(); // Skip unwanted entries
                }).toList(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}