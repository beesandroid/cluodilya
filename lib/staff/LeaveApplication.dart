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

  bool _isFormValid() {
    return _selectedLeaveType != null &&
        _reasonController.text.isNotEmpty &&
        _fromDate != null &&
        _toDate != null &&
        (_fromDate != _toDate || _leaveDuration != null);
  }

  void _addLeaveApplication() {
    if (_isFormValid()) {
      bool canAdd = true;
      for (var application in _leaveApplications) {
        if (application['AbsenceType'] == _selectedLeaveType['absenceType']) {
          canAdd = false;
          _showErrorDialog('The same type of leave cannot be selected twice.');
          break;
        }
      }

      if (canAdd) {
        for (var application in _leaveApplications) {
          DateTime existingFromDate =
              DateFormat('yyyy-MM-dd').parse(application['FromDate']);
          DateTime existingToDate =
              DateFormat('yyyy-MM-dd').parse(application['ToDate']);
          if (!(_toDate!.isBefore(existingFromDate) ||
              _fromDate!.isAfter(existingToDate))) {
            canAdd = false;
            _showErrorDialog(
                'Leave application for the selected date range already exists.');
            break;
          }
        }
      }
      if (canAdd) {
        final leaveApplication = {
          'AbsenceType': _selectedLeaveType['absenceType'],
          'FromDate': DateFormat('yyyy-MM-dd').format(_fromDate!),
          'ToDate': DateFormat('yyyy-MM-dd').format(_toDate!),
          'LeaveDuration': _calculateSelectedDays(),
          'Reason': _reasonController.text,
        };
        setState(() {
          _leaveApplications.add(leaveApplication);
          _selectedLeaveType = null;
          _reasonController.clear();
          _fromDate = null;
          _toDate = null;
          _leaveDuration = null;
        });
      }
    }
  }

  void _continueWithAdjustment() async {
    final requestBody = {
      "GrpCode": "bees",
      "CollegeId": 1,
      "ColCode": "0001",
      "EmployeeId": 2,
      "ApplicationId": 0,
      "Flag": "REVIEW",
      "UserId": 759,
      "AttachFile": " ",
      "Reason": _reasonController.text,
      "LeaveApplicationSaveTablevariable": _leaveApplications.map((application) {
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

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplication'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ACCESS_TOKEN', // Add authorization if required
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        setState(() {
          datesList = List<Map<String, dynamic>>.from(parsedResponse['datesMultiList']);
          periodsList = List<Map<String, dynamic>>.from(parsedResponse['periodsList']);
          facultyList = List<Map<String, dynamic>>.from(parsedResponse['facultyDropdownList']);
          programWiseDisplayList = List<Map<String, dynamic>>.from(parsedResponse['programWiseDisplayList']);
          facultyDropdownList = List<Map<String, dynamic>>.from(parsedResponse['facultyDropdownList']);
        });

        // Call the success dialog or next steps here
        _showSuccessDialog();

        print('Leave application submitted successfully');
      } else {
        // Handle the response error here
        print('Failed to submit leave application: ${response.statusCode}');
        Fluttertoast.showToast(
            msg: "Failed to submit leave application.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } catch (e) {
      // Handle any exceptions or errors here
      print('Error: $e');
      Fluttertoast.showToast(
          msg: "An error occurred while submitting leave application.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Leave Application',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Select Leave Type',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
              RichText(
                text: TextSpan(
                  text: 'Leave ID: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['leaveId']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Accrual Period: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['accrualPeriodName']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Accrued: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['accrued']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Absence Type: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['absenceTypeName']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Accrual Period: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['accrualPeriod']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Balance: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '${_selectedLeaveType!['balance']}',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.0),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for Leave',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fromDate == null
                        ? 'Select From Date'
                        : DateFormat.yMd().format(_fromDate!),
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectFromDate(context),
                  child: Text(
                    'From Date',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _toDate == null
                        ? 'Select To Date'
                        : DateFormat.yMd().format(_toDate!),
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectToDate(context),
                  child: Text(
                    'To Date',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ],
            ),
            if (_fromDate != null &&
                _toDate != null &&
                _fromDate == _toDate &&
                _leaveDuration != null) ...[
              SizedBox(height: 16.0),
              RichText(
                text: TextSpan(
                  text: 'Leave Duration: ',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: '$_leaveDuration',
                        style: TextStyle(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Selected Days: ',
                style: TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: '${_calculateSelectedDays()}',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: _isFormValid() ? _addLeaveApplication : null,
                    child: Text('Add', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (_leaveApplications.isNotEmpty) ...[
              Text('Leave Applications:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _leaveApplications.length,
                itemBuilder: (context, index) {
                  final application = _leaveApplications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          text: 'AbsenceType: ',
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: '${application['AbsenceType']}',
                                style:
                                    TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          text:
                              'From: ${application['FromDate']} - To: ${application['ToDate']}\n',
                          style: TextStyle(color: Colors.blueGrey),
                          children: [
                            TextSpan(
                                text:
                                    'Duration: ${application['LeaveDuration']} days\n',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: 'Reason: ${application['Reason']}',
                                style:
                                    TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _continueWithAdjustment,
                        child: Text(
                          "Continue with adjustment",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              )


            ],
          ],
        ),
      ),
    );
  }


  void _showFacultySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Free Faculty'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: facultyDropdownList.length,
              itemBuilder: (context, index) {
                final faculty = facultyDropdownList[index];
                return ListTile(
                  title: Text(faculty['freeFacultyName']),
                  subtitle: Text(faculty['freeFacultyEmail']),
                  onTap: () {
                    setState(() {
                      _selectedFaculty = faculty['freeFacultyName'];
                    });
                    Navigator.of(context).pop();

                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Leave applied successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Pop the leave application screen
              },
            ),
          ],
        );
      },
    );
  }
}
