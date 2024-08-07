import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? _editingRequestId;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    // Ensure _selectedOutTime is not null before using it
    if (_outTimeDisplayList.isNotEmpty) {
      _selectedOutTime = _outTimeDisplayList.firstWhere(
        (item) => item['id'] == _selectedOutTime?['id'],
        orElse: () => null,
      );
    }
  }

  Future<void> _fetchRequests() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentHostelRequest'),
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
        print(data);
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
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/OutRequestTimeDisplay'),
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
          if (_isEditing) {
            // Check if _selectedOutTime is still valid
            _selectedOutTime = _outTimeDisplayList.firstWhere(
              (item) => item['id'] == _selectedOutTime?['id'],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No record selected'),
        ),
      );
      return;
    }
    final deleteId = _selectedOutTime?['id'];

    try {
      final requestBody = {
        'GrpCode': 'BEES',
        'ColCode': '0001',
        'CollegeId': '1',
        'Id': (flag == 'DELETE' || flag == 'OVERWRITE')
            ? (_editingRequestId ?? 0).toString()
            : '0',
        'StudentId': '2548',
        'Date': _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : '',
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

      if (flag == 'DELETE') {
        requestBody['Id'] = deleteId?.toString() ?? '0';
      }

      print("Request Body: " + requestBody.toString());

      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentHostelRequest'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _initializeRequestState();
        print(data);

        setState(() {
          _responseList = data['saveStudentHostelRequestList'] ?? [];
          _message = data['message'] ?? '';
          if (flag == 'CREATE') {
            _initializeRequestState();
          }
          _fetchRequests(); // Refresh the list
        });

        // Display message from the response in a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Request processed successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }
  void _editRequest(dynamic request) {
    setState(() {
      _selectedOutTime = request;
      _startTimeController.text = request['requestStartTime'] ?? '';
      _endTimeController.text = request['requestEndTime'] ?? '';
      _descriptionController.text = request['description'] ?? '';
      _contactController.text = request['contact'] ?? '';
      _selectedDate =
          request['date'] != null ? DateTime.parse(request['date']) : null;
      _isEditing = true;
      _editingRequestId = request['id'];
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
      _selectedOutTime = request; // Store the request to be deleted
    });

    _sendRequest('DELETE').then((_) {
      // After deletion, update the state
      setState(() {
        // Option 1: Set _selectedOutTime to null
        _selectedOutTime = null;

        // Option 2: Set _selectedOutTime to the first valid item
        // if there are still items in the list
        if (_outTimeDisplayList.isNotEmpty) {
          _selectedOutTime = _outTimeDisplayList.firstWhere(
            (item) => item['id'] != request['id'], // Avoid the deleted item
            orElse: () => null,
          );
        }
      });

      // Fetch the updated list of requests
      _fetchRequests();
      _initializeRequestState();
    });
  }

  void _initializeRequestState() {
    setState(() {
      _selectedOutTime = null;
      _startTimeController.clear();
      _endTimeController.clear();
      _descriptionController.clear();
      _contactController.clear();
      _selectedDate = null;
      _isEditing = false;

      _editingRequestId = null;
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
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'ID: ${_editingRequestId}', // Display ID when editing
                        style: TextStyle(fontSize: 16),
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
                      _startTimeController.text =
                          _selectedOutTime['startTime'] ?? '';
                      _endTimeController.text =
                          _selectedOutTime['endTime'] ?? '';
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
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  final RegExp phoneExp = RegExp(r'^\d{10}$');
                  if (!phoneExp.hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
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
                      onPressed: () =>
                          _sendRequest(_isEditing ? 'OVERWRITE' : 'CREATE'),
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
                      child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.circular(15)),
                        child:
                        ListTile(
                          title: Text(
                              'Selected Timings:${item['date']} ${item['requestStartTime']} - ${item['requestEndTime']}',style: TextStyle(fontWeight: FontWeight.bold),),
                          subtitle: Text(
                              'Description: ${item['description']} \nContact: +91 ${item['contact']} \nid:${item['id']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editRequest(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Are you sure?"),
                                        content: Text(
                                            "Do you really want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete"),
                                            onPressed: () {
                                              _deleteRequest(item);
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
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
