import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'leavemodel.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key});

  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  bool _showDetails = false;
  bool _isFormValid = false;
  List<String> _periods = [];
  List<Map<String, dynamic>> _freeFacultyList = [];
  List<Map<String, dynamic>> _displayOfClassesList = [];
  List<Map<String, dynamic>> _selectedFacultyDetails = [];
  TextEditingController _reasonController= TextEditingController();

  List<DropdownMenuItem<String>> _generateDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    // Iterate through _submittedApplications and add dropdown items for each date range
    for (var application in _submittedApplications) {
      String fromDate = application['singleList']['fromDate'];
      String toDate = application['singleList']['toDate'];

      // Convert fromDate and toDate to 'yyyy-MM-dd' format
      String formattedFromDate = convertDateFormat(fromDate);
      String formattedToDate = convertDateFormat(toDate);

      // Convert to DateTime objects
      DateTime startDate = DateTime.parse(formattedFromDate);
      DateTime endDate = DateTime.parse(formattedToDate);

      // Iterate through each day between startDate and endDate
      for (DateTime date = startDate;
          date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
          date = date.add(Duration(days: 1))) {
        String formattedDate = '${date.year}-${date.month}-${date.day}';
        items.add(DropdownMenuItem<String>(
          value: formattedDate,
          child: Text(formattedDate),
        ));
      }
    }

    return items;
  }

  bool _isDateInRange(String fromDate, String toDate) {
    if (_selectedDateRange == null || !_selectedDateRange!.contains(' to ')) {
      return false; // No valid range selected
    }

    List<String> rangeParts = _selectedDateRange!.split(' to ');
    if (rangeParts.length != 2) {
      throw Exception('Invalid date range format');
    }

    DateTime? selectedStartDate = DateTime.tryParse(rangeParts[0]);
    DateTime? selectedEndDate = DateTime.tryParse(rangeParts[1]);

    if (selectedStartDate == null || selectedEndDate == null) {
      throw Exception('Invalid date format in selected date range');
    }

    DateTime? appStartDate = DateTime.tryParse(fromDate);
    DateTime? appEndDate = DateTime.tryParse(toDate);

    if (appStartDate == null || appEndDate == null) {
      throw Exception('Invalid date format in application date range');
    }

    if (appStartDate.isBefore(selectedEndDate) &&
        appEndDate.isAfter(selectedStartDate)) {
      return true;
    } else {
      return false;
    }
  }

  String convertDateFormat(String inputDate) {
    List<String> parts = inputDate.split('-');
    if (parts.length != 3) {
      throw Exception('Invalid date format');
    }

    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  late Future<List<LeaveData>> _leaveData;
  String? _selectedDateRange;
  String? _selectedPeriod;

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
    _selectedPeriod = _periods.isNotEmpty ? _periods[0] : null;
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
        "EmployeeId": "1",
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

  Future<void> _fetchPeriodsFromApi(String? selectedDate) async {
    // Replace with your actual API endpoint
    String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CloudilyaPeriodDropDown';

    // Replace with your request payload
    Map<String, dynamic> requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "1",
      "Date": selectedDate ?? "",
      // Use selected date or default to empty string
    };

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        print(response.body.toString());
        // Parse response JSON
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> periodsList = jsonResponse['periodDropDownList'];

        // Extract periods from API response
        List<String> periods = periodsList
            .map((period) =>
                '${period['periods']}') // Adjust this as per your API response structure
            .toList();

        setState(() {
          _periods = periods; // Update periods list
        });
      } else {
        throw Exception('Failed to fetch periods from API');
      }
    } catch (e) {
      print('Error fetching periods: $e');
      // Handle error
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

  String? _selectedProgramId;
  String? _selectedBranchId;
  String? _selectedSemesterId;
  String? _selectedSectionId;
  String? _selectedCourseId;

  Future<void> _fetchClassesFromApi(String? selectedPeriod) async {
    String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CloudilyaDisplayOfClasses';

    // Replace with your request payload
    Map<String, dynamic> requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "1",
      "Periods": selectedPeriod ?? "",
      "Date": _selectedDateRange ?? "",
    };

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> displayOfClassesList =
            jsonResponse['displayOfClassesList'];

        for (var classInfo in displayOfClassesList) {
          print('sectionId: ${classInfo['sectionId']}');
          print('courseId: ${classInfo['courseId']}');
          print('semId: ${classInfo['semId']}');
          print('branchId: ${classInfo['branchId']}');
          print('programId: ${classInfo['programId']}');
          print('----------------------');

          setState(() {
            _selectedProgramId = classInfo['programId'].toString();
            _selectedBranchId = classInfo['branchId'].toString();
            _selectedSemesterId = classInfo['semId'].toString();
            _selectedSectionId = classInfo['sectionId'].toString();
            _selectedCourseId = classInfo['courseId'].toString();
          });
        }

        setState(() {
          _displayOfClassesList =
              displayOfClassesList.cast<Map<String, dynamic>>();
        });

        await _fetchFreeFacultiesFromApi(selectedPeriod, _selectedDateRange);
      } else {
        throw Exception('Failed to fetch classes from API');
      }
    } catch (e) {
      print('Error fetching classes: $e');
    }
  }

  Future<void> _fetchFreeFacultiesFromApi(
      String? newValue, String? selectedDateRange) async {
    String apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/ClassAdjustmentFreeFaculty';
    Map<String, dynamic> requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "1",
      "ApplicationId": "0",
      "Flag": "REVIEW",
      "Date": selectedDateRange ?? "",
      "ProgramId": _selectedProgramId ?? "",
      "BranchId": _selectedBranchId ?? "",
      "SemId": _selectedSemesterId ?? "",
      "SectionId": _selectedSectionId ?? "",
      "CourseId": 0,
      "Periods": _selectedPeriod ?? "",
    };
    print(requestBody);

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        print(response.body);
        // Parse response JSON
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> facultiesList = jsonResponse['multiList'];

        // Extract free faculties from API response
        List<Map<String, dynamic>> faculties = facultiesList
            .map((faculty) => {
                  'freeFacultyId': faculty['freeFacultyId'],
                  'freeFacultyName': faculty['freeFacultyName'],
                  'freeFacultyEmail': faculty['freeFacultyEmail'],
                  'freeFacultyPhoneNumber': faculty['freeFacultyPhoneNumber'],
                })
            .toList();

        setState(() {
          _freeFacultyList = faculties; // Update free faculties list
        });
      } else {
        throw Exception('Failed to fetch free faculties from API');
      }
    } catch (e) {
      print('Error fetching free faculties: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      setState(() {
                                        _submittedApplications.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text('From: ${application['fromDate']}'),
                              SizedBox(height: 8),
                              Text('To: ${application['toDate']}'),
                              SizedBox(height: 8),
                              Text('Reason: ${application['reason']}'),
                              SizedBox(height: 8),
                              Text(
                                  'leaveDurationSession: ${application['leaveDurationSession']}'),
                              SizedBox(height: 8),
                              Text(
                                  'leaveDuration: ${application['leaveDuration']}'),
                              SizedBox(height: 8),
                              Text('Attachment: ${application['attachFile']}'),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDetails = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Continue with Adjustment'),
                    ),
                    SizedBox(height: 16),
                    Visibility(
                      visible: _showDetails,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton<String>(
                            hint: Text('Select Date Range'),
                            value: _selectedDateRange,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDateRange = newValue;
                                _fetchPeriodsFromApi(newValue);
                              });
                            },
                            items: _generateDropdownItems(),
                          ),
                          SizedBox(height: 16),
                          DropdownButton<String>(
                            hint: Text('Select Period'),
                            value: _selectedPeriod,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPeriod = newValue;
                                _fetchClassesFromApi(newValue);
                                _fetchFreeFacultiesFromApi(
                                    newValue, _selectedDateRange);
                              });
                            },
                            items: _periods.map((String period) {
                              return DropdownMenuItem<String>(
                                value: period,
                                child: Text(period),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          if (_displayOfClassesList.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _displayOfClassesList.map((classInfo) {
                                return Container(
                                  padding: EdgeInsets.all(16.0),
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Program: ${classInfo['programName']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Branch: ${classInfo['branchName']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800]),
                                      ),
                                      Text(
                                        'Semester: ${classInfo['semester']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800]),
                                      ),
                                      Text(
                                        'Section: ${classInfo['section']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800]),
                                      ),
                                      Text(
                                        'Course: ${classInfo['courseName']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800]),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 18,
                                              color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            '${classInfo['startTime']} - ${classInfo['endTime']}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 16),
                          if (_freeFacultyList.isNotEmpty)
                            DropdownButton<Map<String, dynamic>>(
                              hint: Text('Select Free Faculty'),
                              value: null,
                              onChanged: (Map<String, dynamic>? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    var selectedData = {
                                      'date': _selectedDateRange,
                                      'period': _selectedPeriod,
                                      'programName': newValue['programName'],
                                      'branchName': newValue['branchName'],
                                      'semester': newValue['semester'],
                                      'section': newValue['section'],
                                      'courseName': newValue['courseName'],
                                      'startTime': newValue['startTime'],
                                      'endTime': newValue['endTime'],
                                      'facultyName':
                                          newValue['freeFacultyName'],
                                    };
                                    _selectedFacultyDetails.add(selectedData);
                                  });
                                }
                              },
                              items: _freeFacultyList.map((faculty) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: faculty,
                                  child: Text('${faculty['freeFacultyName']}'),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 16),
                          if (_selectedFacultyDetails.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _selectedFacultyDetails.length,
                              itemBuilder: (context, index) {
                                final detail = _selectedFacultyDetails[index];
                                return Container(
                                  padding: EdgeInsets.all(16.0),
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Faculty: ${detail['facultyName']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text('Date: ${detail['date']}'),
                                      SizedBox(height: 8),
                                      Text('Period: ${detail['period']}'),
                                      SizedBox(height: 8),
                                      Text('Program: ${detail['programName']}'),
                                      SizedBox(height: 8),
                                      Text('Branch: ${detail['branchName']}'),
                                      SizedBox(height: 8),
                                      Text('Semester: ${detail['semester']}'),
                                      SizedBox(height: 8),
                                      Text('Section: ${detail['section']}'),
                                      SizedBox(height: 8),
                                      Text('Course: ${detail['courseName']}'),
                                      SizedBox(height: 8),
                                      Text(
                                          'Time: ${detail['startTime']} - ${detail['endTime']}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
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
              controller: _reasonController,
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
              onPressed: _isFormValid ? _adjustLeaveApplication : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 8,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
    bool isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _validateForm();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Center(
          child: Text(
            period,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black87,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _validateForm() {
    bool isValidDateRange = _fromDate != null && _toDate != null;
    bool isSameDay = isValidDateRange && _fromDate!.isAtSameMomentAs(_toDate!);
    bool isPeriodSelected = !isSameDay || (_selectedPeriod != null);

    setState(() {
      _isFormValid = isValidDateRange &&
          (!isSameDay || isPeriodSelected) &&
          _reasonController.text.isNotEmpty && // Check other required fields
          (_fromDate != null && _toDate != null); // Ensure dates are selected
    });
  }

  Future<void> _adjustLeaveApplication() async {
    final fromDateStr = _fromDate?.toIso8601String().split('T').first ?? '';
    final toDateStr = _toDate?.toIso8601String().split('T').first ?? '';

    // Default leave duration calculation
    int leaveDuration = 0;

    // Adjust leave duration based on selected period
    if (_fromDate != null && _toDate != null) {
      if (_fromDate!.isAtSameMomentAs(_toDate!)) {
        // If same day, adjust duration based on period
        switch (_selectedPeriod) {
          case 'Afternoon':
            leaveDuration = 1; // Half day
            break;
          case 'Forenoon':
            leaveDuration = 0; // Half day
            break;
          case 'Full Day':
            leaveDuration = 2; // Full day
            break;
          default:
            leaveDuration = 0; // No valid period selected
            break;
        }
      } else {
        // If different dates, calculate full days
        leaveDuration = _toDate!.difference(_fromDate!).inDays + 1;
      }
    }

    final attachFileName =
        _selectedFile != null ? _selectedFile!.path.split('/').last : '';

    final requestBody = {
      "GrpCode": "bees",
      "CollegeId": "1",
      "ColCode": "0001",
      "EmployeeId": "1",
      "ApplicationId": "0",
      "Flag": "REVIEW",
      "UserId": "0",
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
        final Map<String, dynamic> data = json.decode(response.body);
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
