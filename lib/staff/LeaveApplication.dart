import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'leavemodel.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key});

  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late Future<List<LeaveData>> _leaveData;
  int? _selectedRowIndex;
  int? _LeaveId;
  String? _selectedAbsenceName;
  String _reason = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  File? _selectedFile;
  String _daysTaken = '';
  String? _selectedPeriodType;
  bool _isSaveButtonEnabled = false;

  double _balance = 0.0;
  List<Map<String, dynamic>> _submittedApplications = [];

  @override
  void initState() {
    super.initState();
    _leaveData = fetchLeaveData();
  }

  Future<List<LeaveData>> fetchLeaveData() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "2",
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      final List<dynamic> jsonList = data['employeeLeavesDisplayList'];
      return jsonList.map((json) => LeaveData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load leave data');
    }
  }

  void _onRowTapped(int index, LeaveData data) {
    setState(() {
      _selectedRowIndex = index;
      _selectedAbsenceName = data.absenceName;
      _LeaveId = data.leaveId;

      _balance = data.balance;
      _reason = '';
      _fromDate = null;
      _toDate = null;
      _selectedFile = null;
      _daysTaken = '';
      _selectedPeriodType = null;
    });
  }

  void _calculateDaysTaken() {
    if (_fromDate != null && _toDate != null) {
      final difference =
          _toDate!.difference(_fromDate!).inDays + 1; // Including the from date
      setState(() {
        if (difference > _balance) {
          _daysTaken = 'Exceeds available balance of $_balance days';
        } else {
          _daysTaken = difference == 0
              ? _selectedPeriodType != null
                  ? 'Selected period: $_selectedPeriodType'
                  : 'Period not selected'
              : '$difference days';
        }
      });
    }
  }

  void _clearSelections() {
    setState(() {
      _selectedRowIndex = null;
      _selectedAbsenceName = null;
      _LeaveId = null;
      _reason = '';
      _fromDate = null;
      _toDate = null;
      _selectedFile = null;
      _daysTaken = '';
      _selectedPeriodType = null;
      _isSaveButtonEnabled = false;
    });
  }

  void _removeSubmittedApplication(int index) {
    setState(() {
      _submittedApplications.removeAt(index);
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(title: const Text('Leave Application')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<LeaveData>>(
              future: _leaveData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No leave data available'));
                } else {
                  final leaveData = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blue),
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(
                            label: Text('Absence Name',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Accrual Period',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Balance',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Last Accrued Date',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Accrued',
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: List.generate(leaveData.length, (index) {
                        final data = leaveData[index];
                        final isSelected = _selectedRowIndex == index;
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) =>
                              isSelected
                                  ? Colors.blue.withOpacity(
                                      0.3) // Background glow effect
                                  : Colors.transparent),
                          cells: [
                            _buildDataCell(data.absenceName, index, data),
                            _buildDataCell(data.accrualPeriodName, index, data),
                            _buildDataCell(
                                data.balance.toString(), index, data),
                            _buildDataCell(data.lastAccruedDate, index, data),
                            _buildDataCell(
                                data.accrued.toString(), index, data),
                          ],
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            if (_selectedAbsenceName != null) _buildDetailContainer(),
            if (_submittedApplications.isNotEmpty)
              Container(
                margin: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted Applications:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _submittedApplications.length,
                      itemBuilder: (context, index) {
                        final application =
                            _submittedApplications[index]['singleList'];
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          margin: EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Leave Type: ${application['absenceTypeName']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                    onPressed: () {
                                      // Remove the application from the list
                                      setState(() {
                                        _submittedApplications.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'From: ${application['fromDate']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'To: ${application['toDate']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Reason: ${application['reason']}',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Attachment: ${application['attachFile']}',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle the "Continue with Adjustment" button press
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                              ),
                              elevation: 8,
                              // Shadow elevation
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              // Padding inside the button
                              textStyle: TextStyle(
                                fontSize: 16, // Text size
                                fontWeight: FontWeight.bold, // Text weight
                              ),
                            ),
                            child: Text('Continue with Adjustment'),
                          ),
                          SizedBox(width: 16),
                          // Add some spacing between the buttons
                          ElevatedButton(
                            onPressed: () {
                              // Handle the "Continue without Adjustment" button press
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                              ),
                              elevation: 8,
                              // Shadow elevation
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              // Padding inside the button
                              textStyle: TextStyle(
                                fontSize: 16, // Text size
                                fontWeight: FontWeight.bold, // Text weight
                              ),
                            ),
                            child: Text('Continue without Adjustment'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text, int index, LeaveData data) {
    return DataCell(
      InkWell(
        onTap: () => _onRowTapped(index, data),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildDetailContainer() {
    return Material(
      elevation: 44,
      shadowColor: Colors.blue,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Selected Absence: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: _selectedAbsenceName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  TextSpan(
                    text: _LeaveId.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              style: TextStyle(color: Colors.black87),
              onChanged: (value) {
                setState(() {
                  _reason = value;
                  _validateForm();
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, color: Colors.black87),
                    label: Text(
                      'From Date: ${_fromDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.blueGrey[100],
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _fromDate = pickedDate;
                          _calculateDaysTaken();
                          _validateForm();
                        });
                      }
                    },
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today, color: Colors.black87),
                  label: Text(
                    'To Date: ${_toDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.blueGrey[100],
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _toDate = pickedDate;
                        _calculateDaysTaken();
                        _validateForm();
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Days taken: ',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      TextSpan(
                        text: _daysTaken,
                        style: TextStyle(
                          color: _daysTaken.contains('Exceeds')
                              ? Colors.red
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Only show period options if 'From' and 'To' dates are the same
                if (_fromDate != null &&
                    _toDate != null &&
                    _fromDate!.isAtSameMomentAs(_toDate!))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectablePeriodOption('Full Day'),
                      _buildSelectablePeriodOption('Afternoon'),
                      _buildSelectablePeriodOption('Forenoon'),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  _selectedFile != null
                      ? 'Selected file: ${_selectedFile!.path.split('/').last}'
                      : 'Pick a file',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _adjustLeaveApplication,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 8, // Shadow elevation
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Padding inside the button
                textStyle: TextStyle(
                  fontSize: 18, // Text size
                  fontWeight: FontWeight.bold, // Text weight
                ),
              ),
              child: const Text('Submit Leave Application'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectablePeriodOption(String period) {
    return ListTile(
      title: Text(period),
      leading: Radio<String>(
        value: period,
        groupValue: _selectedPeriodType,
        onChanged: (value) {
          setState(() {
            _selectedPeriodType = value;
            _calculateDaysTaken();
            _validateForm();
          });
        },
      ),
    );
  }

  void _validateForm() {
    setState(() {
      _isSaveButtonEnabled = _selectedAbsenceName != null &&
          _LeaveId != null &&
          _reason.isNotEmpty &&
          _fromDate != null &&
          _toDate != null &&
          _daysTaken.isNotEmpty &&
          !_daysTaken.startsWith('Exceeds');
    });
  }

  Future<void> _adjustLeaveApplication() async {
    final fromDateStr = _fromDate?.toIso8601String().split('T').first ?? '';
    final toDateStr = _toDate?.toIso8601String().split('T').first ?? '';
    final leaveDuration = _fromDate != null && _toDate != null
        ? _toDate!.difference(_fromDate!).inDays
        : 0;
    final attachFileName =
        _selectedFile != null ? _selectedFile!.path.split('/').last : '';

    final requestBody = {
      "GrpCode": "bees",
      "CollegeId": "1",
      "ColCode": "0001",
      "EmployeeId": "49",
      "ApplicationId": "0",
      "Flag": "REVIEW",
      "UserId": "716",
      "AttachFile1": attachFileName,
      "Reason1": _reason,
      "LeaveApplicationSaveTablevariable": [
        {
          "AbsenceType": _LeaveId,
          "FromDate": fromDateStr,
          "ToDate": toDateStr,
          "LeaveDuration": leaveDuration,
          "Reason": _reason,
          "AttachFile": attachFileName,
        }
      ]
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplication'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data =
            json.decode(response.body);
        setState(() {

            _reason = '';
            _fromDate = null;
            _toDate = null;
            _daysTaken = '';
            _selectedFile = null;
            _selectedAbsenceName = '';
            _LeaveId = 0; // or whatever default value you prefer

          // Now you can correctly add the decoded data to the list
          _submittedApplications.add(data);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave application submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit leave application')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }
}
