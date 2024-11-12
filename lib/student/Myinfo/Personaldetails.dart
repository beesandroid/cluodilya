import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // For persistent storage

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final _formKey = GlobalKey<FormState>();
  List<PlatformFile>? _selectedFiles;

  final String _personalDetailsApiUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentPersonalDetalisDisplay';
  final String _savePersonalDetailsApiUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentPersonalDetalisDisplay'; // Replace with actual save URL

  // Personal Details Map with both IDs and Names
  Map<String, dynamic> _personalDetails = {
    "name": "",
    "genderId": 0,
    "genderName": "",
    "dateOfBirth": "",
    "fatherName": "",
    "fatherOccupation": "",
    "motherName": "",
    "motherTongueId": 0,
    "motherTongueName": "",
    "motherOccupation": "",
    "nationalityId": 0,
    "nationalityName": "",
    "religionId": 0,
    "religionName": "",
    "casteCategoryId": 0,
    "casteCategoryName": "",
    "casteId": 0,
    "casteName": "",
    "bloodGroupId": 0,
    "bloodGroupName": "",
    "programName": "",
    "admissionTypeId": 0,
    "admissionTypeName": "",
    "mobile": "",
    "studentEmail": "",
    "studMobile": "",
    "mole1": "",
    "mole2": "",
    "rationCardNo": "",
    "passPortNo": "",
    "panCardNo": "",
    "bankAccountNo": "",
    "voterId": "",
    "bankId": 0,
    "bankName": "",
    "bankBranch": "",
    "ifscCode": "",
    "drivingLicenceNo": "",
    "aadharNo": "",
    "fatherAadharNo": "",
    "motherAadharNo": "",
    "nationalIdentityNo": "",
    "changeReason": ""
  };

  // Dropdown Lists (if any dropdowns are needed in the future)
  List<dynamic> banks = [];

  bool isLoading = true; // To manage loading state
  bool isEditing = false; // To manage edit state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch Personal Details and Bank Dropdown List
  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String studId = prefs.getString('studId') ?? '';

    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "HallTicketNo": userName,
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
      "ProgramName": "",
      "AdmissionTypeId": "0",
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
      "Flag": "VIEW",
      "StudentAddressTable": {}
    };

    // Print the request body to verify its contents
    print("Request body: ${json.encode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse(_personalDetailsApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: $data");
        if (data['studentPersonalDetalisDisplayList'] != null &&
            data['studentPersonalDetalisDisplayList'].isNotEmpty) {
          final personalDetails = data['studentPersonalDetalisDisplayList'][0];
          setState(() {
            _personalDetails = {
              "name": personalDetails["name"] ?? "",
              "genderId": personalDetails["gender"] ?? 0,
              "genderName": personalDetails["genderName"] ?? "",
              "dateOfBirth": personalDetails["dateOfBirth"] ?? "",
              "fatherName": personalDetails["fatherName"] ?? "",
              "fatherOccupation": personalDetails["fatherOccupation"] ?? "",
              "motherName": personalDetails["motherName"] ?? "",
              "motherTongueId": personalDetails["motherTongue"] ?? 0,
              "motherTongueName": personalDetails["motherTongueName"] ?? "",
              "motherOccupation": personalDetails["motherOccupation"] ?? "",
              "nationalityId": personalDetails["nationality"] ?? 0,
              "nationalityName": personalDetails["nationalityName"] ?? "",
              "religionId": personalDetails["religion"] ?? 0,
              "religionName": personalDetails["religionName"] ?? "",
              "casteCategoryId": personalDetails["casteCategory"] ?? 0,
              "casteCategoryName": personalDetails["castecategoryName"] ?? "",
              "casteId": personalDetails["caste"] ?? 0,
              "casteName": personalDetails["casteName"] ?? "",
              "bloodGroupId": personalDetails["bloodGroupId"] ?? 0,
              "bloodGroupName": personalDetails["bloodGroupName"] ?? "",
              "programName": personalDetails["programName"] ?? "",
              "admissionTypeId": personalDetails["admissionType"] ?? 0,
              "admissionTypeName": personalDetails["admissionTypeName"] ?? "",
              "mobile": personalDetails["studMobile"] ?? "",
              "studentEmail": personalDetails["studentEmail"] ?? "",
              "studMobile": personalDetails["studMobile"] ?? "",
              "mole1": personalDetails["mole1"] ?? "",
              "mole2": personalDetails["mole2"] ?? "",
              "rationCardNo": personalDetails["rationCardNo"] ?? "",
              "passPortNo": personalDetails["passPortNo"] ?? "",
              "panCardNo": personalDetails["panCardNo"] ?? "",
              "bankAccountNo": personalDetails["bankAccountNo"] ?? "",
              "voterId": personalDetails["voterId"] ?? "",
              "bankId": personalDetails["bank"] ?? 0,
              "bankName": personalDetails["bankName"] ?? "",
              "bankBranch": personalDetails["bankBranch"] ?? "",
              "ifscCode": personalDetails["ifscCode"] ?? "",
              "drivingLicenceNo": personalDetails["drivingLicenceNo"] ?? "",
              "aadharNo": personalDetails["aadharNo"] ?? "",
              "fatherAadharNo": personalDetails["fatherAadharNo"] ?? "",
              "motherAadharNo": personalDetails["motherAadharNo"] ?? "",
              "nationalIdentityNo": personalDetails["nationalIdentityNo"] ?? "",
              "changeReason": personalDetails["changeReason"] ?? "",
            };

            // Extract bank dropdown list
            banks = personalDetails["bankNameDopDownList"] ?? [];
          });
        } else {
          print('No personal details found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No personal details found')),
          );
        }
      } else {
        print('Failed to load personal details');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load personal details')),
        );
      }
    } catch (e) {
      print('Error fetching personal details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Pick Files
  Future<void> _pickFiles() async {
    if (!isEditing) return; // Prevent picking files when not editing
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  // Save Files and Personal Details
  Future<void> saveFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';

    if (!isEditing) return; // Prevent saving files when not editing
    if (_selectedFiles == null || _selectedFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files selected')),
      );
      return;
    }

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveApprovalFiles');
    final filesData = _selectedFiles!.map((file) {
      return {
        "StudentId": studId,
        "File": file.name, // Send the file name directly
      };
    }).toList();

    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "AddressId": "0",
      "ActivityId": "0",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "PERSONAL",
      "SaveApprovalFilesUploadingtablevariable": filesData,
    };

    print(
        'Request Body for Saving Files: ${json.encode(requestBody)}'); // Debugging

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Save Files Response: $data");
        _saveData(); // Save form data after saving files

        final message = data['message'] ?? 'Files saved successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _selectedFiles
              ?.clear(); // Clear selected files after successful upload
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save files')),
        );
      }
    } catch (e) {
      print('Error saving files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Save Personal Details
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String userName = prefs.getString('userName') ?? '';

    if (!isEditing) return; // Only save if in editing mode
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prepare request body with IDs where necessary
    final requestBody = {
      "GrpCode": "beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "HallTicketNo": userName,
      "Flag": "OVERWRITE",
      "name": _personalDetails["name"] ?? "",
      "gender": _personalDetails["genderId"] ?? 0,
      "dateOfBirth": _personalDetails["dateOfBirth"] ?? "",
      "fatherName": _personalDetails["fatherName"] ?? "",
      "fatherOccupation": _personalDetails["fatherOccupation"] ?? "",
      "motherName": _personalDetails["motherName"] ?? "",
      "motherTongue": _personalDetails["motherTongueId"] ?? 0,
      "motherOccupation": _personalDetails["motherOccupation"] ?? "",
      "nationality": _personalDetails["nationalityId"] ?? 0,
      "religion": _personalDetails["religionId"] ?? 0,
      "casteCategory": _personalDetails["casteCategoryId"] ?? 0,
      "caste": _personalDetails["casteId"] ?? 0,
      "bloodGroupId": _personalDetails["bloodGroupId"] ?? 0,
      "programName": _personalDetails["programName"] ?? "",
      "admissionTypeId": _personalDetails["admissionTypeId"] ?? 0,
      "mobile": _personalDetails["mobile"] ?? "",
      "studentEmail": _personalDetails["studentEmail"] ?? "",
      "studMobile": _personalDetails["studMobile"] ?? "",
      "mole1": _personalDetails["mole1"] ?? "",
      "mole2": _personalDetails["mole2"] ?? "",
      "rationCardNo": _personalDetails["rationCardNo"] ?? "",
      "passPortNo": _personalDetails["passPortNo"] ?? "",
      "panCardNo": _personalDetails["panCardNo"] ?? "",
      "bankAccountNo": _personalDetails["bankAccountNo"] ?? "",
      "voterId": _personalDetails["voterId"] ?? "",
      "bank": _personalDetails["bankId"] ?? 0,
      "bankBranch": _personalDetails["bankBranch"] ?? "",
      "IFSCCode": _personalDetails["ifscCode"] ?? "",
      "drivingLicenceNo": _personalDetails["drivingLicenceNo"] ?? "",
      "aadharNo": _personalDetails["aadharNo"] ?? "",
      "fatherAadharNo": _personalDetails["fatherAadharNo"] ?? "",
      "motherAadharNo": _personalDetails["motherAadharNo"] ?? "",
      "nationalIdentityNo": _personalDetails["nationalIdentityNo"] ?? "",
      "changeReason": _personalDetails["changeReason"] ?? "",
    };

    print(
        'Request Body for Saving Data: ${json.encode(requestBody)}'); // Debugging

    try {
      final response = await http.post(
        Uri.parse(_savePersonalDetailsApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final message = responseData['message'] ?? 'No message';
        print("Save Data Response: $responseData");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        if (message.toLowerCase().contains('success')) {
          await _fetchData(); // Reload data
          setState(() {
            isEditing = false; // Disable editing after successful save
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save data')),
        );
      }
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Build Read-Only or Editable Text Field
  Widget _buildTextField(String label, String key,
      {bool isDate = false, bool isEditable = true, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: _personalDetails[key]?.toString() ?? '',
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
          // Optional
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: isDate ? TextInputType.datetime : TextInputType.text,
        enabled: isEditable,
        // Enable based on edit state
        readOnly: isDate && !isEditable,
        // Read-only if not editable
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: (value) {
          setState(() {
            _personalDetails[key] = value.isNotEmpty ? value : "";
          });
        },
        validator: (value) {
          // Add specific validations if required
          return null;
        },
        cursorColor: Colors.white,
        onTap: isDate
            ? () async {
                if (!isEditing) return;
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _personalDetails["dateOfBirth"] != ""
                      ? DateTime.tryParse(_personalDetails["dateOfBirth"]) ??
                          DateTime.now()
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.blue, // Header background color
                          onPrimary:
                              Colors.white, // Header text color (e.g., title)
                          onSurface: Colors
                              .black, // Body text color (e.g., selected date)
                        ),
                        dialogBackgroundColor: Colors
                            .white, // Background color for the date picker
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    _personalDetails[key] = formattedDate;
                  });
                }
              }
            : null,
      ),
    );
  }

  // Build Change Reason Text Field (Editable in edit mode)
  Widget _buildChangeReasonField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: _personalDetails[key]?.toString() ?? '',
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: const Icon(Icons.edit, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.text,
        enabled: isEditing,
        // Enable based on edit state
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: (value) {
          setState(() {
            _personalDetails[key] = value.isNotEmpty ? value : "";
          });
        },
        validator: (value) {
          if (isEditing && (value == null || value.isEmpty)) {
            return 'Please provide a reason for change';
          }
          return null;
        },
        cursorColor: Colors.white,
      ),
    );
  }

  // Build Bank Dropdown (Only Bank Dropdown is editable)
  Widget _buildBankDropdown(String label, String key, List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<int>(
        value: _personalDetails[key] != null && _personalDetails[key] != 0
            ? _personalDetails[key] as int
            : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: const Icon(Icons.account_balance, color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dropdownColor: Colors.blueGrey.shade700,
        iconEnabledColor: Colors.white70,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        items: options.map<DropdownMenuItem<int>>((option) {
          return DropdownMenuItem<int>(
            value: option['lookUpId'],
            child: Text(option['meaning'] ?? 'No Name',
                style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: isEditing
            ? (value) {
                setState(() {
                  _personalDetails[key] = value ?? 0;
                  // If you have a corresponding name field, update it
                  // For example, if you have 'bankName' field
                  _personalDetails['bankName'] = options.firstWhere(
                          (option) => option['lookUpId'] == value,
                          orElse: () => null)?['meaning'] ??
                      '';
                });
              }
            : null,
        // Disable onChange if not editing
        validator: (value) {
          // Optionally add validation
          return null;
        },
      ),
    );
  }

  // Build File Picker Button
  Widget _buildFilePickerButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onPressed: isEditing ? _pickFiles : null,
      icon: const Icon(Icons.attach_file),
      label: const Text(
        'Pick Files',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Build Save Button
  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onPressed: isEditing ? saveFiles : null,
      icon: const Icon(Icons.save),
      label: const Text(
        'Save',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Stack to overlay gradient background
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main Content with SafeArea
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
                        'Personal Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isEditing ? Icons.cancel : Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isEditing) {
                              // If canceling edit, reload data to discard changes
                              _fetchData();
                            }
                            isEditing = !isEditing;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
        children: [
          // Personal Details Fields
          _buildTextField('Name', 'name',
              icon: Icons.person, isEditable: false),
          _buildTextField('Gender', 'genderName',
              icon: Icons.wc, isEditable: false), // Read-only
          _buildTextField('Date of Birth', 'dateOfBirth',
              isDate: false, icon: Icons.calendar_today, isEditable: false),
          _buildTextField('Father Name', 'fatherName',
              icon: Icons.person, isEditable: false),
          _buildTextField('Father Occupation', 'fatherOccupation',
              icon: Icons.work, isEditable: false),
          _buildTextField('Mother Name', 'motherName',
              icon: Icons.person, isEditable: false),
          _buildTextField('Mother Tongue', 'motherTongueName',
              icon: Icons.language, isEditable: false), // Read-only
          _buildTextField('Mother Occupation', 'motherOccupation',
              icon: Icons.work, isEditable: false),
          _buildTextField('Nationality', 'nationalityName',
              icon: Icons.flag, isEditable: false), // Read-only
          _buildTextField('Religion', 'religionName',
              icon: Icons.book, isEditable: false), // Read-only
          _buildTextField('Caste Category', 'casteCategoryName',
              icon: Icons.category, isEditable: false), // Read-only
          _buildTextField('Caste', 'casteName',
              icon: Icons.list_alt, isEditable: false), // Read-only
          _buildTextField('Blood Group', 'bloodGroupName',
              icon: Icons.bloodtype, isEditable: false), // Read-only
          _buildTextField('Program Name', 'programName',
              icon: Icons.school, isEditable: false), // Read-only
          _buildTextField('Admission Type', 'admissionTypeName',
              icon: Icons.assignment, isEditable: false), // Read-only
          _buildTextField('Mobile', 'mobile',
              icon: Icons.phone, isEditable: false),
          _buildTextField('Student Email', 'studentEmail',
              icon: Icons.email, isEditable: false),
          _buildTextField('Alternate Mobile', 'studMobile',
              icon: Icons.phone, isEditable: false),
          _buildTextField('Mole 1', 'mole1',
              icon: Icons.info, isEditable: false),
          _buildTextField('Mole 2', 'mole2',
              isEditable: false, icon: Icons.info),
          // Editable Fields
          _buildTextField('Ration Card No', 'rationCardNo',
              isEditable: false, icon: Icons.card_membership),
          _buildTextField('Passport No', 'passPortNo',
              isEditable: false, icon: Icons.flight),
          _buildTextField('PAN Card No', 'panCardNo',
              isEditable: false, icon: Icons.credit_card),
          _buildTextField('Bank Account No', 'bankAccountNo',
              isEditable: false, icon: Icons.account_balance_wallet),
          _buildTextField('Voter ID', 'voterId',
              isEditable: false, icon: Icons.how_to_vote),
          // Bank Dropdown (editable)
          _buildBankDropdown('Bank', 'bankId', banks),
          _buildTextField('Bank Branch', 'bankBranch',
              isEditable: isEditing, icon: Icons.location_city),
          _buildTextField('IFSC Code', 'ifscCode',
              isEditable: isEditing, icon: Icons.code),
          _buildTextField('Driving Licence No', 'drivingLicenceNo',
              isEditable: false, icon: Icons.directions_car),
          _buildTextField('Aadhar No', 'aadharNo',
              isEditable: false, icon: Icons.perm_identity),
          _buildTextField('Father Aadhar No', 'fatherAadharNo',
              isEditable: false, icon: Icons.perm_identity),
          _buildTextField('Mother Aadhar No', 'motherAadharNo',
              isEditable: false, icon: Icons.perm_identity),
          _buildTextField('National Identity No', 'nationalIdentityNo',
              isEditable: false, icon: Icons.fingerprint),
          // Change Reason Field (editable)
          _buildChangeReasonField('Change Reason', 'changeReason'),
          const SizedBox(height: 20),
          // File Picker Button
          _buildFilePickerButton(),
          if (_selectedFiles != null && _selectedFiles!.isNotEmpty)
            Column(
              children: _selectedFiles!.map((file) {
                return ListTile(
                  title: Text(
                    file.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${(file.size / 1024).toStringAsFixed(2)} KB',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedFiles!.remove(file);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }
}
