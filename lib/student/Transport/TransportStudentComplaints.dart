import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class StudentComplaintsScreen extends StatefulWidget {
  @override
  _StudentComplaintsScreenState createState() => _StudentComplaintsScreenState();
}

class _StudentComplaintsScreenState extends State<StudentComplaintsScreen> {
  List<Map<String, dynamic>> complaintTypes = [];
  List<Map<String, dynamic>> complaintRequests = [];
  int? selectedComplaintTypeId;
  DateTime? selectedDate;
  TextEditingController complaintDescriptionController = TextEditingController();
  String? selectedFilePath;
  int? selectedComplaintId;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchComplaintTypes();
    fetchComplaintRequests();
  }

  Future<void> fetchComplaintTypes() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintTypeDropdown'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "Flag": "TRANSPORTCOMPLAINTTYPE" // Changed Flag to Transport
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        complaintTypes = List<Map<String, dynamic>>.from(data['complaintTypeDropdownList']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaint types')),
      );
    }
  }

  Future<void> fetchComplaintRequests() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "ComplaintId": 0,
        "StudentId": "2548",
        "EmployeeId": 0,
        "ComplaintDescription": "",
        "TypeOfComplaint": 0,
        "File": "",
        "ComplaintDate": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "Transport", // Changed Flag to Transport
        "SubFlag": "VIEW"
      }),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        complaintRequests = List<Map<String, dynamic>>.from(data['complaintRequestList']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaint requests')),
      );
    }
  }

  Future<void> sendComplaint() async {
    String registrationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (selectedComplaintTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a complaint type.')),
      );
      return;
    }

    final requestBody = json.encode({
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "ComplaintId": selectedComplaintId ?? 0,
      "StudentId": "2548",
      "EmployeeId": 0,
      "ComplaintDescription": complaintDescriptionController.text,
      "TypeOfComplaint": selectedComplaintTypeId,
      "File": selectedFilePath ?? "",
      "ComplaintDate": selectedDate.toString(),
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "Transport", // Changed Flag to Transport
      "SubFlag": isEditing ? "OVERWRITE" : "CREATE"
    });

    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      if (data['message'] == "You are already rise a complaint") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint already exists.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Complaint modified successfully.' : 'Complaint sent successfully.')),
        );
        resetForm();
        fetchComplaintRequests();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send complaint')),
      );
    }
  }

  Future<void> deleteComplaint(int complaintId) async {
    setState(() {
      complaintRequests.removeWhere((complaint) => complaint['complaintId'] == complaintId);
    });

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ComplaintRequestDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "ComplaintId": complaintId,
        "StudentId": "2548",
        "EmployeeId": 0,
        "ComplaintDescription": "",
        "TypeOfComplaint": 0,
        "File": "",
        "ComplaintDate": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "Transport", // Changed Flag to Transport
        "SubFlag": "DELETE"
      }),
    );

    final data = json.decode(response.body);

    print('Delete Response Status Code: ${response.statusCode}');
    print('Delete Response Body: ${response.body}');

    if (response.statusCode == 200) {
      if (data['message'] == "Complaint deleted successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete complaint')),
      );
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Complaint Type',
                  border: OutlineInputBorder(),
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
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
                  ),
                  child: Text(selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'No Date Chosen'),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: complaintDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Complaint Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: pickFile,
                child: Text('Pick File', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              if(selectedFilePath!=null)
              Text(selectedFilePath.toString()),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: sendComplaint,
                child: Text(isEditing ? 'Modify Complaint' : 'Send Complaint', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Complaint Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: complaintRequests.length,
                itemBuilder: (context, index) {
                  final complaint = complaintRequests[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(complaint['complaintDescription'],style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text('Date: ${complaint['complaintDate']}  \ncomplaintDescription: ${complaint['complaintDescription']}\file: ${complaint['file']}'),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  selectedComplaintId = complaint['complaintId'];
                                  selectedComplaintTypeId = complaint['typeOfComplaint'];
                                  complaintDescriptionController.text = complaint['complaintDescription'];
                                  selectedDate = DateTime.parse(complaint['complaintDate']);
                                  isEditing = true;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteComplaint(complaint['complaintId']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
