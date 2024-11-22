import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentComplaintsScreen extends StatefulWidget {
  @override
  _StudentComplaintsScreenState createState() =>
      _StudentComplaintsScreenState();
}

class _StudentComplaintsScreenState extends State<StudentComplaintsScreen> {
  List<Map<String, dynamic>> complaintTypes = [];
  List<Map<String, dynamic>> complaintRequests = [];
  int? selectedComplaintTypeId;
  DateTime? selectedDate;
  TextEditingController complaintDescriptionController =
  TextEditingController();
  String? selectedFilePath;
  int? selectedComplaintId;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchComplaintTypes();
    fetchComplaintRequests();
  }

  Future<void> fetchComplaintTypes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintTypeDropdown'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": "Bees",
          "ColCode": "0001",
          "Flag": "HOSTELCOMPLAINTTYPE"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Complaint Types: ${response.body}');
        setState(() {
          complaintTypes = List<Map<String, dynamic>>.from(
              data['complaintTypeDropdownList']);
        });
      } else {
        showSnackBar('Failed to load complaint types');
      }
    } catch (e) {
      showSnackBar('An error occurred while fetching complaint types');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchComplaintRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": grpCode,
          "ColCode": colCode,
          "CollegeId": "1",
          "ComplaintId": 0,
          "StudentId": studId,
          "EmployeeId": 0,
          "ComplaintDescription": "",
          "TypeOfComplaint": 0,
          "File": "",
          "ComplaintDate": "",
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "Hostel",
          "SubFlag": "VIEW"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Complaint Requests: ${response.body}');
        setState(() {
          complaintRequests =
          List<Map<String, dynamic>>.from(data['complaintRequestList']);
        });
      } else {
        showSnackBar('Failed to load complaint requests');
      }
    } catch (e) {
      showSnackBar('An error occurred while fetching complaint requests');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendComplaint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCode = prefs.getString('grpCode') ?? '';

    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';

    if (selectedComplaintTypeId == null) {
      showSnackBar('Please select a complaint type.');
      return;
    }
    if (complaintDescriptionController.text.trim().isEmpty) {
      showSnackBar('Please enter a complaint description.');
      return;
    }
    if (selectedDate == null) {
      showSnackBar('Please select a date.');
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    final requestBody = json.encode({
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": "1",
      "ComplaintId": selectedComplaintId ?? 0,
      "StudentId": studId,
      "EmployeeId": 0,
      "ComplaintDescription": complaintDescriptionController.text.trim(),
      "TypeOfComplaint": selectedComplaintTypeId,
      "File": selectedFilePath ?? "",
      "ComplaintDate": formattedDate,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "Hostel",
      "SubFlag": isEditing ? "OVERWRITE" : "CREATE"
    });

    print('Sending Complaint: $requestBody');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        if (data['message'] == "You are already rise a complaint") {
          showSnackBar('Complaint already exists.');
        } else {
          showSnackBar(isEditing
              ? 'Complaint modified successfully.'
              : 'Complaint sent successfully.');
          resetForm();
          fetchComplaintRequests();
        }
      } else {
        showSnackBar('Failed to send complaint');
      }
    } catch (e) {
      showSnackBar('An error occurred while sending complaint');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteComplaint(int complaintId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    setState(() {
      isLoading = true;
    });

    // Optimistically remove the complaint from the list first
    setState(() {
      complaintRequests
          .removeWhere((complaint) => complaint['complaintId'] == complaintId);
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": grpCode,
          "ColCode": colCode,
          "CollegeId": "1",
          "ComplaintId": complaintId,
          "StudentId": studId,
          "EmployeeId": 0,
          "ComplaintDescription": "",
          "TypeOfComplaint": 0,
          "File": "",
          "ComplaintDate": "",
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "Hostel",
          "SubFlag": "DELETE"
        }),
      );

      final data = json.decode(response.body);

      print('Delete Response: ${response.body}');

      if (response.statusCode == 200) {
        if (data['message'] == "Complaint deleted successfully") {
          showSnackBar(data['message']);
        } else {
          showSnackBar(data['message']);
        }
      } else {
        showSnackBar('Failed to delete complaint');
      }
    } catch (e) {
      showSnackBar('An error occurred while deleting complaint');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  void resetForm() {
    setState(() {
      selectedComplaintTypeId = null;
      selectedDate = null;
      complaintDescriptionController.clear();
      selectedFilePath = null;
      selectedComplaintId = null;
      isEditing = false;
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // Dismiss keyboard
            },
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Complaint Form Card
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    shadowColor: Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Complaint Type Dropdown
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Complaint Type',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            value: selectedComplaintTypeId,
                            onChanged: (newValue) {
                              setState(() {
                                selectedComplaintTypeId = newValue;
                              });
                            },
                            items: complaintTypes.map((type) {
                              return DropdownMenuItem<int>(
                                value: type['complaintId'],
                                child: Text(type['complaintName']),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a complaint type.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Date Picker
                          GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null && pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Select Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!)
                                        : 'No Date Chosen',
                                    style: TextStyle(
                                      color: selectedDate != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    Icons.date_range,
                                    color: Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Complaint Description
                          TextField(
                            controller: complaintDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Complaint Description',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            maxLines: 4,
                          ),
                          SizedBox(height: 20),
                          // File Picker
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: pickFile,
                                icon: Icon(Icons.attach_file,color: Colors.white,),
                                label: Text('Pick File',style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  selectedFilePath != null
                                      ? 'Selected: ${selectedFilePath!.split('/').last}'
                                      : 'No File Selected',
                                  style: TextStyle(
                                    color: selectedFilePath != null
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: sendComplaint,
                              icon: Icon(
                                isEditing ? Icons.edit : Icons.send,
                                color: Colors.white,
                              ),
                              label: Text(
                                isEditing
                                    ? 'Modify Complaint'
                                    : 'Send Complaint',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Complaint History Section
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Text(
                      'Complaint History',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  complaintRequests.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: complaintRequests.length,
                    itemBuilder: (context, index) {
                      final complaint = complaintRequests[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3,
                          shadowColor: Colors.grey.shade200,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // Complaint Header
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        complaint['typeOfComplaintName'] ??
                                            'No Type',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.green),
                                          onPressed: () {
                                            setState(() {
                                              selectedComplaintId =
                                              complaint['complaintId'];
                                              selectedComplaintTypeId =
                                              complaint['typeOfComplaint'];
                                              complaintDescriptionController
                                                  .text =
                                                  complaint[
                                                  'complaintDescription'] ??
                                                      '';
                                              selectedDate =
                                              complaint['complaintDate'] !=
                                                  null
                                                  ? DateTime.parse(complaint[
                                              'complaintDate'])
                                                  : null;
                                              selectedFilePath =
                                                  complaint['file'] ?? null;
                                              isEditing = true;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      "Delete Complaint"),
                                                  content: Text(
                                                      "Are you sure you want to delete this complaint?"),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        deleteComplaint(
                                                            complaint[
                                                            'complaintId']);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Complaint Details
                                Text(
                                  'Date: ${complaint['complaintDate'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(complaint['complaintDate'])) : 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Status: ${complaint['status'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 5),
                                if (complaint['file'] != null &&
                                    complaint['file'].isNotEmpty)
                                  Text(
                                    'File: ${complaint['file'].split('/').last}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                if (complaint['complaintDescription'] !=
                                    null &&
                                    complaint['complaintDescription']
                                        .isNotEmpty)
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Description: ${complaint['complaintDescription']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No complaints found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading Indicator Overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
