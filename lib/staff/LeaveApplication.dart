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
  List<Map<String, dynamic>> _addedFacultyList = [];
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
  List<Map<String, dynamic>> facultyList = [];

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
      firstDate: DateTime.now(),
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
      firstDate: DateTime.now(),
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

  bool _isFacultyDuplicate(Map<String, dynamic> faculty) {
    return _addedFacultyList.any((existingFaculty) =>
    existingFaculty['date'] == faculty['date'] &&
        existingFaculty['period'] == faculty['period'] &&
        existingFaculty['faculty'] == faculty['faculty'] &&
        existingFaculty['freeFaculty'] == faculty['freeFaculty'] &&
        existingFaculty['startTime'] == faculty['startTime'] &&
        existingFaculty['endTime'] == faculty['endTime']);
  }

  void _addFaculty() {
    if (_selectedDate != null &&
        _selectedPeriod != null &&
        _selectedFaculty != null) {
      // Find the selected faculty
      final selectedFaculty = facultyList.firstWhere(
              (faculty) =>
          faculty['date'] == _selectedDate &&
              faculty['period'] == _selectedPeriod &&
              faculty['freeFacultyName'] == _selectedFaculty,
          orElse: () => {
            'freeFaculty': 'N/A' // Provide a default value if not found
          });

      // Find the corresponding program details for the selected date and period
      final programDetails = programWiseDisplayList.firstWhere(
              (program) =>
          program['dates'] == _selectedDate &&
              program['period'] == _selectedPeriod,
          orElse: () => {
            'startTime': 'N/A',
            'endTime': 'N/A',
          });

      final newFaculty = {
        'date': _selectedDate!,
        'period': _selectedPeriod!,
        'faculty': _selectedFaculty!,
        'freeFaculty': selectedFaculty['freeFaculty'],
        'startTime': programDetails['startTime'],
        'endTime': programDetails['endTime'],
      };

      if (!_isFacultyDuplicate(newFaculty)) {
        setState(() {
          _addedFacultyList.add(newFaculty);
          // Clear selections
          _selectedDate = null;
          _selectedPeriod = null;
          _selectedFaculty = null;
        });
      } else {
        // Optionally show a message indicating the faculty is a duplicate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This faculty entry already exists.'),
          ),
        );
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
        if (application['leaveId'] == _selectedLeaveType!['leaveId']) {
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
          'leaveId': _selectedLeaveType!['leaveId'], // Include leaveId
          'AbsenceType': _selectedLeaveType!['absenceTypeName'],
          'FromDate': DateFormat('yyyy-MM-dd').format(_fromDate!),
          'ToDate': DateFormat('yyyy-MM-dd').format(_toDate!),
          'LeaveDuration': _calculateSelectedDays(),
          'Reason': _reasonController.text,
          'AccrualPeriodName': _selectedLeaveType!['accrualPeriodName'],
          'Accrued': _selectedLeaveType!['accrued'],
          'Balance': _selectedLeaveType!['balance'],
        };
        setState(() {
          _leaveApplications.add(leaveApplication);
          _selectedLeaveType = null;
          _reasonController.clear();
          _fromDate = null;
          _toDate = null;
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

      // Check for the specific message in the response
      if (parsedResponse['message'] ==
          "Dates Overlapped Check Once With Existed Records") {
        Fluttertoast.showToast(
          msg: "Dates overlapped with existing records. Please review.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
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
        print('Leave application submitted successfully');
      }
    } else {
      print('Failed to submit leave application');
      Fluttertoast.showToast(
        msg: "Failed to submit leave application.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _applyLeave() async {
    var dateFormat = DateFormat('yyyy-MM-dd'); // Define the output date format
    var inputDateFormat = DateFormat('dd-MM-yyyy');
    var payload = {
      "GrpCode": "Bees",
      "CollegeId": "1",
      "ColCode": "0001",
      "EmployeeId": "2",
      "ApplicationId": "0",
      "Flag": "CREATE",
      "UserId": "1",
      "AttachFile": "",
      "Reason": _reasonController.text,
      "SaveLeaveApplicationEmployee": _addedFacultyList.map((faculty) {
        DateTime parsedDate = inputDateFormat.parse(faculty['date']);
        String formattedDate = dateFormat.format(parsedDate);
        return {
          "ApplicationId": 0,
          "AdjustmentId": "0",
          "StartTime": faculty['startTime'],
          "EndTime": faculty['endTime'],
          "Periods": faculty['period'],
          "Date": formattedDate,
          "Faculty": "2",
          "FreeFaculty": faculty['freeFaculty']
        };
      }).toList(),
      "LeaveApplicationSaveTablevariable":
          _leaveApplications.map((application) {
        return {
          "AbsenceId": application['leaveId'], // Directly use the leaveId
          "FromDate": application['FromDate'],
          "ToDate": application['ToDate'],
          "LeaveDuration": application['LeaveDuration'],
          "Reason": application['Reason'],
          "AttachFile": ""
        };
      }).toList()
    };

    print('Request payload: ${json.encode(payload)}');

    var response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplicationSave'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print(responseData);
      if (responseData['message'] == 'Dates Overlapped Check Once') {
        _showOverlapDialog();
      } else if (responseData['message'] == 'Record is Successfully Saved') {
        _showSuccessDialog();
      } else {
        _showErrorDialog('${responseData['message']}');
      }
    } else {
      _showErrorDialog(
          'Failed to submit leave application: ${response.statusCode}');
    }
  }

  void _showOverlapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Dates Overlapped Check Once'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('OK'),
            ),
          ],
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
          content: Text('Record is Successfully Saved'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Container(color: Colors.white,
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
                print('Application Data: $application');
                print('Leave ID: ${application['leaveId']}');
                return Material(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color to white
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.black, // Set border color to black
                        width: 1.0, // Set border width
                      ),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Absence Type: ',
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                    text: '${application['leaveId']}',
                                    style: TextStyle(fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          text: 'From: ${application['FromDate']} - To: ${application['ToDate']}\n',
                          style: TextStyle(color: Colors.blueGrey),
                          children: [
                            TextSpan(
                                text: 'Duration: ${application['LeaveDuration']} days\n',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: 'Reason: ${application['Reason']}',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )

            ,
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
                      child: Text("Continue with adjustment",
                          style: TextStyle(color: Colors.white)),
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
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Date',
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
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
                  labelStyle: TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                    labelStyle: TextStyle(color: Colors.blueGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
            if (_selectedDate != null &&
                _selectedPeriod != null &&
                _selectedFaculty != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _addFaculty,
                    child: Text('Add Faculty',
                        style: TextStyle(color: Colors.white)),
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
            ],
            SizedBox(height: 16.0),
            if (_addedFacultyList.isNotEmpty) ...[
              Text('Added Faculty:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _addedFacultyList.length,
                itemBuilder: (context, index) {
                  final faculty = _addedFacultyList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          text: 'Date: ',
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: '${faculty['date']}',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          text: 'Period: ${faculty['period']}\n',
                          style: TextStyle(color: Colors.blueGrey),
                          children: [
                            TextSpan(
                                text: 'Faculty: ${faculty['faculty']}\n',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                            TextSpan(
                                text: 'Free Faculty: ${faculty['freeFaculty']}\n',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                            TextSpan(
                                text: 'Start Time: ${faculty['startTime']}\n',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                            TextSpan(
                                text: 'End Time: ${faculty['endTime']}',
                                style: TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      trailing: TextButton(
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          setState(() {
                            _addedFacultyList.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: _applyLeave,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue), // Background color
                        foregroundColor: MaterialStateProperty.all(Colors.white), // Text color
                      ),
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),
            ]

          ],
        ]),
      ),
    );
  }
}
