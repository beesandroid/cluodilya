import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({Key? key}) : super(key: key);

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _filePath;
  List<dynamic> _leaveRequestList = [];
  int? _editRequestId;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "BeesDEV",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": "0",
        "StudentId": "2548",
        "EmployeeId": "0",
        "Description": "",
        "Subject": "",
        "RequestDate": "2024-08-12",
        "FromDate": "",
        "ToDate": "",
        "File": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data); // Log the complete response

      // Check if 'studentLeaveRequestList' exists and is a list
      if (data['studentLeaveRequestList'] != null &&
          data['studentLeaveRequestList'] is List) {
        setState(() {
          _leaveRequestList = data['studentLeaveRequestList'];
        });
      } else {
        setState(() {
          _leaveRequestList = []; // Handle case where there are no requests
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No leave requests found')),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load leave requests')),
      );
    }
  }

  Future<void> _sendLeaveRequest() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _fromDate == null ||
        _toDate == null ||
        _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    final flag = _editRequestId == null ? "CREATE" : "OVERWRITE";
    final requestId = _editRequestId ?? 0;

    final requestBody = {
      "GrpCode": "BeesDEV",
      "ColCode": "0001",
      "CollegeId": "1",
      "Id": requestId,
      "StudentId": "2548",
      "EmployeeId": "0",
      "RequestDate": "2024-08-12",
      "Description": _descriptionController.text,
      "Subject": _subjectController.text,
      "FromDate": _fromDate?.toIso8601String(),
      "ToDate": _toDate?.toIso8601String(),
      "File": _filePath,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag
    };

    // Print request body
    print('Request Body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      _fetchLeaveRequests();
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody.toString());

      final String message = responseBody['message'];
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }

      setState(() {
        _editRequestId = null;
        _subjectController.clear();
        _descriptionController.clear();
        _fromDate = null;
        _toDate = null;
        _filePath = null;
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send leave request')),
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _modifyLeaveRequest(int index) {
    final request = _leaveRequestList[index];
    setState(() {
      _editRequestId = request['id'];
      _subjectController.text = request['subject'] ?? '';
      _descriptionController.text = request['description'] ?? '';
      _fromDate = DateTime.tryParse(request['fromDate']);
      _toDate = DateTime.tryParse(request['toDate']);
      _filePath = request['file'];
    });
  }

  void _confirmDeleteLeaveRequest(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this leave request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLeaveRequest(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLeaveRequest(int index) async {
    final request = _leaveRequestList[index];
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "BeesDEV",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": request['id'],
        "StudentId": "2548",
        "EmployeeId": "0",
        "Description": "",
        "RequestDate": "2024-08-12",
        "Subject": "",
        "FromDate": "",
        "ToDate": "",
        "File": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "DELETE"
      }),
    );

    if (response.statusCode == 200) {
      _fetchLeaveRequests();
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final String message = responseBody['message'];
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete leave request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Leave Request',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_subjectController, 'Subject'),
              const SizedBox(height: 8),
              _buildTextField(_descriptionController, 'Description',
                  maxLines: 3),
              const SizedBox(height: 8),
              Container(
                  child: _buildDatePicker('Select From Date', _fromDate,
                      () => _selectDate(context, true))),
              _buildDatePicker(
                  'Select To Date', _toDate, () => _selectDate(context, false)),
              _buildFilePicker(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sendLeaveRequest,
                child: Text(
                    _editRequestId == null ? 'Send Request' : 'Modify Request'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Leave Request List:",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaveRequestList.length,
                itemBuilder: (context, index) {
                  final request = _leaveRequestList[index];
                  return Card(
                    color: Colors.white,
                    elevation: 10,
                    // Adds a shadow effect
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  request['subject'] ?? 'No Subject',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                    onPressed: () => _modifyLeaveRequest(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _confirmDeleteLeaveRequest(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            request['description'] ?? 'No Description',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'From: ${request['fromDate']?.split('T')[0] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              Text(
                                'To: ${request['toDate']?.split('T')[0] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.blue),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  request['file'] ?? 'No file chosen',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  overflow: TextOverflow
                                      .ellipsis, // Ensures long text doesn't overflow
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: onTap,
          child: Text(label),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          date != null
              ? date.toIso8601String().split('T')[0]
              : 'No date chosen',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          child: const Text('Choose File'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _filePath != null ? _filePath!.split('/').last : 'No file chosen',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
