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
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": "0",
        "StudentId": "2548",
        "EmployeeId": "0",
        "Description": "",
        "Subject": "",
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
      final Map<String, dynamic> responseBody = json.decode(response.body);

      final String message = responseBody['message'];
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
      setState(() {
        _leaveRequestList = data['leaveRequestList'];
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load leave requests')),
      );
    }
  }

  Future<void> _sendLeaveRequest() async {
    final flag = _editRequestId == null ? "CREATE" : "OVERWRITE";
    final requestId = _editRequestId ?? 0;

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": requestId,
        "StudentId": "2548",
        "EmployeeId": "0",
        "Description": _descriptionController.text,
        "Subject": _subjectController.text,
        "FromDate": _fromDate?.toIso8601String(),
        "ToDate": _toDate?.toIso8601String(),
        "File": _filePath,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": flag
      }),
    );

    if (response.statusCode == 200) {
      _fetchLeaveRequests();
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);

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
          content: const Text('Are you sure you want to delete this leave request?'),
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
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": request['id'],
        "StudentId": "2548",
        "EmployeeId": "0",
        "Description": "",
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
      appBar: AppBar(
        title: const Text('Leave Request'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_subjectController, 'Subject'),
              const SizedBox(height: 8),
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              const SizedBox(height: 8),
              _buildDatePicker('Select From Date', _fromDate, () => _selectDate(context, true)),
              _buildDatePicker('Select To Date', _toDate, () => _selectDate(context, false)),
              _buildFilePicker(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _sendLeaveRequest,
                child: Text(_editRequestId == null ? 'Send Request' : 'Modify Request'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaveRequestList.length,
                itemBuilder: (context, index) {
                  final request = _leaveRequestList[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                request['subject'] ?? 'No Subject',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black),
                                    onPressed: () => _modifyLeaveRequest(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.black),
                                    onPressed: () => _confirmDeleteLeaveRequest(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(request['description'] ?? 'No Description'),
                          const SizedBox(height: 4),
                          Text('From: ${request['fromDate']?.split('T')[0] ?? 'N/A'}'),
                          Text('To: ${request['toDate']?.split('T')[0] ?? 'N/A'}'),
                          const SizedBox(height: 4),
                          Text('File: ${request['file'] ?? 'No file chosen'}'),
                          const SizedBox(height: 8),
                        ],
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

  Widget _buildTextField(TextEditingController controller, String labelText, {int maxLines = 1}) {
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
          date != null ? date.toIso8601String().split('T')[0] : 'No date chosen',
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
