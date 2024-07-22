import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'Service/leave.dart';
import 'package:http/http.dart' as http;

class LeaveApplicationScreen extends StatefulWidget {
  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  List<Map<String, dynamic>> addedFaculties = [];
  List<Map<String, dynamic>> programWiseDisplayList = [];
  List<Map<String, dynamic>> facultyDropdownList = [];
  List<dynamic> _leaveTypes = [];
  dynamic _selectedLeaveType;
  TextEditingController _reasonController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _leaveDuration;
  final LeaveService _leaveService = LeaveService();
  List<Map<String, dynamic>> _leaveApplications = [];
  String? _selectedDate;
  int? _selectedPeriod;
  String? _selectedFaculty;

  List<Map<String, dynamic>> datesList = [];
  List<Map<String, dynamic>> periodsList = [];
  List<Map<String, dynamic>> facultyList =
      []; // List to store leave applications

  @override
  void initState() {
    super.initState();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    try {
      final leaveTypes = await _leaveService.fetchLeaveTypes();
      setState(() {
        _leaveTypes = leaveTypes;
      });
    } catch (e) {
      // Handle the error
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        if (_toDate != null) {
          _validateDateRange();
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
        if (_fromDate != null) {
          _validateDateRange();
          if (_fromDate == _toDate) {
            _promptLeaveDuration(context);
          }
        }
      });
    }
  }

  void _promptLeaveDuration(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Leave Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Full Day'),
                onTap: () {
                  setState(() {
                    _leaveDuration = 'Full Day';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Forenoon'),
                onTap: () {
                  setState(() {
                    _leaveDuration = 'Forenoon';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Afternoon'),
                onTap: () {
                  setState(() {
                    _leaveDuration = 'Afternoon';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _validateDateRange() {
    if (_selectedLeaveType != null) {
      int selectedDays = _calculateSelectedDays();
      double balance = _selectedLeaveType['balance'];
      if (selectedDays > balance) {
        _showErrorDialog(
            'Selected date range exceeds the available balance of ${balance.toStringAsFixed(2)} days.');
        _toDate = null;
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int _calculateSelectedDays() {
    if (_fromDate != null && _toDate != null) {
      return _toDate!.difference(_fromDate!).inDays + 1;
    }
    return 0;
  }

  void _onLeaveTypeChanged(dynamic newValue) {
    setState(() {
      _selectedLeaveType = newValue;
      _reasonController.clear();
      _fromDate = null;
      _toDate = null;
      _leaveDuration = null;
    });
  }

  bool _isFormValid() {
    return _selectedLeaveType != null &&
        _reasonController.text.isNotEmpty &&
        _fromDate != null &&
        _toDate != null &&
        (_fromDate != _toDate || _leaveDuration != null);
  }

  void _addLeaveApplication() {
    if (_isFormValid()) {
      final leaveApplication = {
        'AbsenceType': _selectedLeaveType['absenceType'],
        'FromDate': DateFormat('yyyy-MM-dd').format(_fromDate!),
        'ToDate': DateFormat('yyyy-MM-dd').format(_toDate!),
        'LeaveDuration': _calculateSelectedDays(),
        'Reason': _reasonController.text,
      };

      setState(() {
        _leaveApplications.add(leaveApplication);
        // Clear the form after adding
        _selectedLeaveType = null;
        _reasonController.clear();
        _fromDate = null;
        _toDate = null;
        _leaveDuration = null;
      });
    }
  }

  void _continueWithAdjustment() async {
    final requestBody = {
      "GrpCode": "bees",
      "CollegeId": 1,
      "ColCode": "0001",
      "EmployeeId": 1,
      "ApplicationId": 0,
      "Flag": "REVIEW",
      "UserId": 716,
      "AttachFile": " ",
      "Reason": _reasonController.text,
      "LeaveApplicationSaveTablevariable":
          _leaveApplications.map((application) {
        return {
          "AbsenceType": application['AbsenceType'],
          "FromDate": application['FromDate'],
          "ToDate": application['ToDate'],
          "LeaveDuration": application['LeaveDuration'],
          "Reason": application['Reason'],
          "AttachFile": ""
        };
      }).toList(),
    };
    print(requestBody);

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplication'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body.toString());
      Map<String, dynamic> parsedResponse = json.decode(response.body);

      setState(() {
        datesList =
            List<Map<String, dynamic>>.from(parsedResponse['datesMultiList']);
        periodsList =
            List<Map<String, dynamic>>.from(parsedResponse['periodsList']);
        facultyList = List<Map<String, dynamic>>.from(
            parsedResponse['facultyDropdownList']);
        programWiseDisplayList = List<Map<String, dynamic>>.from(
            parsedResponse['programWiseDisplayList']); // Store the list
        facultyDropdownList = List<Map<String, dynamic>>.from(
            parsedResponse['facultyDropdownList']); // Store the list
      });

      // Handle successful response
      print('Leave application submitted successfully');
    } else {
      // Handle error response
      print('Failed to submit leave application');
    }
  }

  void _removeFaculty(int index) {
    setState(() {
      addedFaculties.removeAt(index);
    });
  }

  void _saveLeaveApplication() async {
    if (_selectedDate == null ||
        _selectedPeriod == null ||
        _selectedFaculty == null) {
      Fluttertoast.showToast(
        msg: 'Please select all required fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Use the stored programWiseDisplayList and facultyDropdownList
    List<dynamic> programWiseDisplayList = this.programWiseDisplayList;
    List<dynamic> facultyDropdownList = this.facultyDropdownList;

    // Find the matching program details
    final programDetails = programWiseDisplayList
        .where((program) =>
            program['dates'] == _selectedDate &&
            program['period'] == _selectedPeriod)
        .toList();

    if (programDetails.isNotEmpty) {
      final program = programDetails.first;
      final startTime = program['startTime'];
      final endTime = program['endTime'];

      // Find the matching free faculty by ID
      final facultyDetails = facultyDropdownList
          .where((faculty) =>
              faculty['date'] == _selectedDate &&
              faculty['period'] == _selectedPeriod &&
              faculty['freeFacultyName'] == _selectedFaculty)
          .toList();

      // Extract free faculty details
      final freeFaculty = facultyDetails.isNotEmpty
          ? facultyDetails.first['freeFaculty'].toString()
          : '';

      // Convert date format from day-month-year to year-month-day
      DateTime parsedDate =
          DateTime.parse(_selectedDate!.split('-').reversed.join('-'));
      String formattedDate =
          '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';

      // Create the final request body with actual StartTime, EndTime, and FreeFaculty
      final finalRequestBody = {
        "GrpCode": "Bees",
        "CollegeId": "1",
        "ColCode": "0001",
        "EmployeeId": "1",
        "ApplicationId": "0",
        "AdjustmentId": "0",
        "Flag": "REVIEW",
        "UserId": "1",
        "LeaveApplicationSaveTablevariable": [
          {
            "ApplicationId": 0,
            "AdjustmentId": "0",
            "StartTime": startTime,
            "EndTime": endTime,
            "Periods": _selectedPeriod,
            "Date": formattedDate,
            "Faculty": "1", // Assuming this is the name
            "FreeFaculty": freeFaculty,
          }
        ]
      };

      // Print the final request body
      print('Final Request Body: ${json.encode(finalRequestBody)}');

      final url =
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplicationSave';
      final headers = {'Content-Type': 'application/json'};

      try {
        final response = await http.post(Uri.parse(url),
            headers: headers, body: json.encode(finalRequestBody));
        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          print(responseBody);

          // Append the new faculty to the existing list
          setState(() {
            addedFaculties.add({
              'facultyName': _selectedFaculty,
              'date': formattedDate,
              'periods': _selectedPeriod,
            });
          });

          Fluttertoast.showToast(
            msg: 'Faculty added successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to save leave application',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      print('No matching program details found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Leave Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Select Leave Type',
              ),
              items: _leaveTypes.map((leave) {
                return DropdownMenuItem<dynamic>(
                  value: leave,
                  child: Text(leave['absenceName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLeaveType = value;
                });
              },
              value: _selectedLeaveType,
            ),
            if (_selectedLeaveType != null) ...[
              SizedBox(height: 16.0),
              Text('Leave ID: ${_selectedLeaveType!['leaveId']}'),
              Text(
                  'Accrual Period: ${_selectedLeaveType!['accrualPeriodName']}'),
              Text('Accrued: ${_selectedLeaveType!['accrued']}'),
              Text('Absence Type: ${_selectedLeaveType!['absenceTypeName']}'),
              Text('Accrual Period: ${_selectedLeaveType!['accrualPeriod']}'),
              Text('Balance: ${_selectedLeaveType!['balance']}'),
            ],
            SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for Leave',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(_fromDate == null
                      ? 'Select From Date'
                      : DateFormat.yMd().format(_fromDate!)),
                ),
                ElevatedButton(
                  onPressed: () => _selectFromDate(context),
                  child: Text('From Date'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(_toDate == null
                      ? 'Select To Date'
                      : DateFormat.yMd().format(_toDate!)),
                ),
                ElevatedButton(
                  onPressed: () => _selectToDate(context),
                  child: Text('To Date'),
                ),
              ],
            ),
            if (_fromDate != null &&
                _toDate != null &&
                _fromDate == _toDate &&
                _leaveDuration != null) ...[
              SizedBox(height: 16.0),
              Text('Leave Duration: $_leaveDuration'),
            ],
            SizedBox(height: 16.0),
            Text('Selected Days: ${_calculateSelectedDays()}'),
            SizedBox(height: 16.0),
            Container(
              child: ElevatedButton(
                onPressed: _isFormValid() ? _addLeaveApplication : null,
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (_leaveApplications.isNotEmpty) ...[
              Text('Leave Applications:'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _leaveApplications.length,
                itemBuilder: (context, index) {
                  final application = _leaveApplications[index];
                  return ListTile(
                    title: Text('AbsenceType: ${application['AbsenceType']}'),
                    subtitle: Text(
                      'From: ${application['FromDate']} - To: ${application['ToDate']}\n'
                      'Duration: ${application['LeaveDuration']} days\n'
                      'Reason: ${application['Reason']}',
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: _continueWithAdjustment,
                child: Text("Continue with adjustment"),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Date',
                ),
                value: _selectedDate,
                items: datesList.map((date) {
                  return DropdownMenuItem<String>(
                    value: date['date'],
                    child: Text(date['date']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDate = newValue;
                    _selectedPeriod = null; // Reset the selected period
                    _selectedFaculty = null; // Reset the selected faculty
                  });
                },
              ),
              SizedBox(height: 16.0),
              if (_selectedDate != null) ...[
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Period',
                  ),
                  value: _selectedPeriod,
                  items: periodsList
                      .where((period) => period['date'] == _selectedDate)
                      .map((period) {
                    return DropdownMenuItem<int>(
                      value: period['period'],
                      child: Text('Period ${period['period']}'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPeriod = newValue;
                      _selectedFaculty = null; // Reset the selected faculty
                    });
                  },
                ),
                SizedBox(height: 16.0),
                if (_selectedPeriod != null) ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Faculty',
                    ),
                    value: _selectedFaculty,
                    items: facultyList
                        .where((faculty) =>
                            faculty['date'] == _selectedDate &&
                            faculty['period'] == _selectedPeriod)
                        .map((faculty) {
                      return DropdownMenuItem<String>(
                        value: faculty['freeFacultyName'],
                        child: Text(faculty['freeFacultyName']),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedFaculty = newValue;
                      });
                    },
                  ),
                ],
              ],
            ],
            if (_selectedDate != null &&
                _selectedPeriod != null &&
                _selectedFaculty != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _saveLeaveApplication,
                      child: Text(
                        'Add Faculty +',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16.0),
            if (addedFaculties.isNotEmpty) ...[
              Text('Added Faculties:'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: addedFaculties.length,
                itemBuilder: (context, index) {
                  final faculty = addedFaculties[index];
                  return ListTile(
                    title: Text(faculty['facultyName'] ?? 'No Name'),
                    subtitle: Text(
                      'Date: ${faculty['date'] ?? 'No Date'}, Period: ${faculty['periods'] ?? 'No Period'}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeFaculty(index);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Apply Leave',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
