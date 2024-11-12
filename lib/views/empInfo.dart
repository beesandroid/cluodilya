import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeeInfo extends StatefulWidget {
  const EmployeeInfo({super.key});

  @override
  State<EmployeeInfo> createState() => _EmployeeInfoState();
}

class _EmployeeInfoState extends State<EmployeeInfo> {
  Map<String, dynamic> _employeeData = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails();
  }

  Future<void> _fetchEmployeeDetails() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "bees",
        "ColCode": "0001",
        "CollegeId": 1,
        "UserId": 1,
        "EmployeeId": "2",
        "FirstName": "",
        "LastName": "",
        "id": 0,
        "StartDate": "",
        "EndDate": "",
        "EffectiveDate": "",
        "PrefixId": 0,
        "PreferredName": "",
        "DateOfBirth": "",
        "MaritalStatus": 0,
        "ChangeReason": "",
        "Nationality": 0,
        "Religion": 0,
        "CasteCategory": 0,
        "Caste": 0,
        "DriversLicenseNumber": "",
        "DriversLicenseExpiryDate": "",
        "PassportNumber": "",
        "PassportExpiryDate": "",
        "RationCardNumber": "",
        "AICTEId": "",
        "UniversityId": "",
        "BiometricId": "",
        "VoterId": "",
        "OfficePhoneNumber": "",
        "PersonalPhoneNumber": "",
        "OfficeEmailAddress": "",
        "PersonalEmailAddress": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "FatherName": "",
        "Flag": "VIEW",
        "CountryOfBirth": 0,
        "BloodGroup": 0,
        "PANCardNumber": "",
        "ProvidentFundNumber": ""
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _employeeData = jsonDecode(response.body)['employeePersonalList'][0];
      });
    } else {
      // Handle error
    }
  }

  Future<void> _updateEmployeeDetails() async {
    // Construct the request body
    final requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": _employeeData['collegeId'],
      "UserId": 1,
      "EmployeeId": _employeeData['employeeId'],
      "FirstName": _employeeData['firstName'],
      "LastName": _employeeData['lastName'],
      "id": _employeeData['id'],
      "StartDate": _employeeData['startDate'],
      "EndDate": _employeeData['endDate'],
      "EffectiveDate": _employeeData['effectiveDate'],
      "PrefixId": _employeeData['prefixId'],
      "PreferredName": _employeeData['preferredName'],
      "DateOfBirth": _employeeData['dateOfBirth'],
      "MaritalStatus": _employeeData['maritalStatus'],
      "ChangeReason": _employeeData['changeReason'],
      "Nationality": _employeeData['nationality'],
      "Religion": _employeeData['religion'],
      "CasteCategory": _employeeData['casteCategory'],
      "Caste": _employeeData['caste'],
      "DriversLicenseNumber": _employeeData['driversLicenseNumber'],
      "DriversLicenseExpiryDate": _employeeData['driversLicenseExpiryDate'],
      "PassportNumber": _employeeData['passportNumber'],
      "PassportExpiryDate": _employeeData['passportExpiryDate'],
      "RationCardNumber": _employeeData['rationCardNumber'],
      "AICTEId": _employeeData['aicteId'],
      "UniversityId": _employeeData['universityId'],
      "BiometricId": _employeeData['biometricId'],
      "VoterId": _employeeData['voterId'],
      "OfficePhoneNumber": _employeeData['officePhoneNumber'],
      "PersonalPhoneNumber": _employeeData['personalPhoneNumber'],
      "OfficeEmailAddress": _employeeData['officeEmailAddress'],
      "PersonalEmailAddress": _employeeData['personalEmailAddress'],
      "LoginIpAddress": _employeeData['loginIpAddress'],
      "LoginSystemName": _employeeData['loginSystemName'],
      "FatherName": _employeeData['fatherName'],
      "Flag": "OVERWRITE",
      "CountryOfBirth": _employeeData['countryOfBirth'],
      "BloodGroup": _employeeData['bloodGroup'],
      "PANCardNumber": _employeeData['panCardNumber'],
      "ProvidentFundNumber": _employeeData['providentFundNumber']
    };

    // Print the request body
    print('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreprod/CloudilyaMobileAPP/SaveEmployeePersonalDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Print the response body
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        _isEditing = false;
      });
      // Handle success
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Personal Information'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateEmployeeDetails();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _employeeData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildTextField('First Name', 'firstName'),
                  _buildTextField('Last Name', 'lastName'),
                  _buildTextField('Preferred Name', 'preferredName'),
                  _buildTextField('Date of Birth', 'dateOfBirth'),
                  _buildTextField('Marital Status', 'maritalStatus'),
                  _buildTextField('Nationality', 'nationality'),
                  _buildTextField('Religion', 'religion'),
                  _buildTextField('Caste Category', 'casteCategory'),
                  _buildTextField('Caste', 'caste'),
                  _buildTextField(
                      'Driver\'s License Number', 'driversLicenseNumber'),
                  _buildTextField('Driver\'s License Expiry Date',
                      'driversLicenseExpiryDate'),
                  _buildTextField('Passport Number', 'passportNumber'),
                  _buildTextField('Passport Expiry Date', 'passportExpiryDate'),
                  _buildTextField('Ration Card Number', 'rationCardNumber'),
                  _buildTextField('AICTE ID', 'aicteId'),
                  _buildTextField('University ID', 'universityId'),
                  _buildTextField('Biometric ID', 'biometricId'),
                  _buildTextField('Voter ID', 'voterId'),
                  _buildTextField('Office Phone Number', 'officePhoneNumber'),
                  _buildTextField(
                      'Personal Phone Number', 'personalPhoneNumber'),
                  _buildTextField('Office Email Address', 'officeEmailAddress'),
                  _buildTextField(
                      'Personal Email Address', 'personalEmailAddress'),
                  _buildTextField('Father Name', 'fatherName'),
                  _buildTextField('Country of Birth', 'countryOfBirth'),
                  _buildTextField('Blood Group', 'bloodGroup'),
                  _buildTextField('PAN Card Number', 'panCardNumber'),
                  _buildTextField(
                      'Provident Fund Number', 'providentFundNumber'),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        enabled: _isEditing,
        controller:
            TextEditingController(text: _employeeData[key]?.toString() ?? ''),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          _employeeData[key] = value;
        },
      ),
    );
  }
}
