import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class OutingRequestScreen extends StatefulWidget {
  @override
  _OutingRequestScreenState createState() => _OutingRequestScreenState();
}

class _OutingRequestScreenState extends State<OutingRequestScreen> {
  DateTime? _selectedDate;
  List<dynamic> _outTimeDisplayList = [];
  dynamic _selectedOutTime;
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  String? _selectedFilePath;
  String _message = '';
  List<dynamic> _responseList = [];
  bool _isEditing = false;
 // Flag to check if editing or creating

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _selectedOutTime = _outTimeDisplayList.firstWhere(
          (item) => item['id'] == _selectedOutTime['id'],
      orElse: () => null,
    );
  }

  Future<void> _fetchRequests() async {
    try {
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentHostelRequest'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'GrpCode': 'BEES',
          'ColCode': '0001',
          'CollegeId': '1',
          'Id': '0',
          'StudentId': '2548',
          'Date': '',
          'DateOfRequest': '',
          'VisitingId': '0',
          'EmployeeId': '0',
          'Description': '',
          'RequestStartTime': '',
          'RequestEndTime': '',
          'Contact': '',
          'File': '',
          'LoginIpAddress': '',
          'LoginSystemName': '',
          'Flag': 'VIEW',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseList = data['saveStudentHostelRequestList'] ?? [];
          _message = data['message'] ?? '';
        });
      } else {
        setState(() {
          _message = 'Failed to fetch requests';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _fetchOutTimeDisplayList() async {
    if (_selectedDate == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/OutRequestTimeDisplay'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'GrpCode': 'Bees',
          'ColCode': '0001',
          'CollegeId': '1',
          'StudentId': '2548',
          'Date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _outTimeDisplayList = data['outTimeDisplayList'] ?? [];
          _message = _outTimeDisplayList.isEmpty ? data['message'] ?? '' : '';
          // If in editing mode, re-select the previously selected out time
          if (_isEditing && _selectedOutTime != null) {
            _selectedOutTime = _outTimeDisplayList.firstWhere(
                  (item) => item['id'] == _selectedOutTime['id'],
              orElse: () => null,
            );
          }
        });
      } else {
        setState(() {
          _message = 'Failed to fetch outing hours';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _sendRequest(String flag) async {
    if (flag != 'VIEW' && _selectedOutTime == null) {
      setState(() {
        _message = 'No record selected';
      });
      return;
    }

    try {
      final requestBody = {
        'GrpCode': 'BEES',
        'ColCode': '0001',
        'CollegeId': '1',
        'Id': flag == 'DELETE' ? (_selectedOutTime?['id'] ?? '0').toString() : '0',
        'StudentId': '2548',
        'Date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'DateOfRequest': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'VisitingId': _selectedOutTime?['visitingId']?.toString() ?? '0',
        'EmployeeId': '0',
        'Description': _descriptionController.text,
        'RequestStartTime': _startTimeController.text,
        'RequestEndTime': _endTimeController.text,
        'Contact': _contactController.text,
        'File': _selectedFilePath ?? '',
        'LoginIpAddress': '',
        'LoginSystemName': '',
        'Flag': flag,
      };

      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentHostelRequest'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseList = data['saveStudentHostelRequestList'] ?? [];
          _message = data['message'] ?? '';
          if (flag == 'CREATE') {
            _initializeRequestState(); // Reset state after creation
          }
          _fetchRequests(); // Refresh the list
        });
      } else {
        setState(() {
          _message = 'Failed to send request';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  void _editRequest(dynamic request) {
    setState(() {
      _selectedOutTime = request;
      _startTimeController.text = request['requestStartTime'];
      _endTimeController.text = request['requestEndTime'];
      _descriptionController.text = request['description'];
      _contactController.text = request['contact'];
      _selectedDate = DateTime.parse(request['date']);
      _isEditing = true; // Set to editing mode
      _fetchOutTimeDisplayList();
    });
  }

  void _deleteRequest(dynamic request) {
    if (request == null || request['id'] == null) {
      setState(() {
        _message = 'Invalid request selected for deletion';
      });
      return;
    }

    setState(() {
      _selectedOutTime = request;
    });
    _sendRequest('DELETE');
  }

  void _initializeRequestState() {
    setState(() {
      _selectedOutTime = null;
      _startTimeController.clear();
      _endTimeController.clear();
      _descriptionController.clear();
      _contactController.clear();
      _selectedDate = null;
      _isEditing = false; // Reset to creating mode
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _message,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              DropdownButtonFormField<dynamic>(
                hint: Text('Select Out Time'),
                value: _selectedOutTime,
                onChanged: (newValue) {
                  setState(() {
                    _selectedOutTime = newValue;
                    if (_selectedOutTime != null) {
                      _startTimeController.text = _selectedOutTime['startTime'];
                      _endTimeController.text = _selectedOutTime['endTime'];
                    }
                  });
                },
                items: _outTimeDisplayList.map((outTime) {
                  return DropdownMenuItem<dynamic>(
                    value: outTime,
                    child: Text(
                      '${outTime['startTime']} - ${outTime['endTime']} (${outTime['permissionTypeName']})',
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 16.0),
              TextField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 120,
                child: ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(
                    'Pick File',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              if (_selectedFilePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Selected file: $_selectedFilePath',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () => _sendRequest(_isEditing ? 'OVERWRITE' : 'CREATE'),
                      child: Text(
                        _isEditing ? 'Modify Request' : 'Send Request',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: _responseList.length,
                  itemBuilder: (context, index) {
                    final item = _responseList[index];
                    return Container(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                            '${item['date']} ${item['requestStartTime']} - ${item['requestEndTime']}'),
                        subtitle: Text(
                            'Description: ${item['description']} \nContact: ${item['contact']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editRequest(item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteRequest(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _fetchOutTimeDisplayList();
      });
    }
  }
}
