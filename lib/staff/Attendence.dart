import 'package:cloudilya/staff/EmpDashboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> _periods = [];
  Map<String, dynamic> _periodData = {};
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  String? _selectedPeriod;
  final TextEditingController _searchController = TextEditingController();
  String _selectedDateText = 'Pick a date';
  bool _allPresent = false; // State to track if all are set to present
  bool _allAbsent = false; // State to track if all are set to absent

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedDateText =
            '${_selectedDate.toLocal()}'.split(' ')[0]; // Update the text
        _selectedPeriod = null;
        _students = [];
        _filteredStudents = [];
        _periods = [];
      });

      String formattedDate = _selectedDateText;
      await _fetchAttendanceData(
          _selectedDateText); // Fetch data with default period value '0'
    }
  }

  Future<void> _fetchAttendanceData(String formattedDate) async {
    final String url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FacultyDailyAttendanceDisplay';

    final Map<String, dynamic> requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "Date": formattedDate,
      "ProgramId": "0",
      "BranchId": "0",
      "SemId": "0",
      "SectionId": "0",
      "EmployeeId": "1099",
      "Perioddisplay": "0",
      "Flag": "FacultyWise"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            'Response data: $data'); // Print entire response data for debugging

        if (data['FacultyDailyAttendanceDisplayList'] != null &&
            data['FacultyDailyAttendanceDisplayList'].isNotEmpty) {
          final attendanceList = data['FacultyDailyAttendanceDisplayList'];

          // Print the outer level Posted field
          if (attendanceList[0] != null &&
              attendanceList[0]['Posted'] != null) {
            print('Outer Posted: ${attendanceList[0]['Posted']}');
          } else {
            print('Outer Posted field not found');
          }

          final periods = attendanceList[0]['Periods'] as Map<String, dynamic>;

          // Print the Posted field for each period
          periods.forEach((key, value) {
            if (value['Posted'] != null) {
              print('Period $key Posted: ${value['Posted']}');
            } else {
              print('Period $key Posted field not found');
            }
          });

          setState(() {
            _periods = periods.keys.toList();
            _periodData = periods;

            // Update students and filtered students based on selected period if available
            if (_selectedPeriod != null &&
                _periodData.containsKey(_selectedPeriod)) {
              _students = _periodData[_selectedPeriod]?['Students'] ?? [];
            } else {
              _students = [];
            }
            _filteredStudents = _students;
          });
        } else {
          print('No attendance data available');
        }
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onPeriodSelected(String? period) {
    if (period == null) return;

    setState(() {
      _selectedPeriod = period;
    });

    // Fetch data for the selected period
    _fetchAttendanceData(_selectedDateText);
  }

  void _toggleAttendance(int index) {
    setState(() {
      final student = _filteredStudents[index];
      student['Attendance'] = student['Attendance'] == 1 ? 0 : 1;

      // Update _students directly if needed
      final originalIndex = _students.indexOf(student);
      if (originalIndex != -1) {
        _students[originalIndex] = student;
      }
    });
  }

  List<PieChartSectionData> _createChartData() {
    int presentCount =
        _filteredStudents.where((student) => student['Attendance'] == 1).length;
    int absentCount = _filteredStudents.length - presentCount;

    final List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: presentCount.toDouble(),
        title:
            '${(presentCount / _filteredStudents.length * 100).toStringAsFixed(1)}%',
        color: Colors.green,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: absentCount.toDouble(),
        title:
            '${(absentCount / _filteredStudents.length * 100).toStringAsFixed(1)}%',
        color: Colors.red,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];

    return sections;
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Attendance Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: double.maxFinite,
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _createChartData(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      startDegreeOffset: 90,
                    ),
                    swapAnimationDuration: Duration(milliseconds: 2000),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  children: _filteredStudents.map((student) {
                    final isPresent = student['Attendance'] == 1;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0),
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            student['StudentName'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPresent ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement save logic here
                Navigator.of(context).pop();
                _saveAttendance();
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _saveAttendance() async {
    final String url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveFacultyWiseAttendance';

    String formattedDate = '${_selectedDate.toLocal()}'.split(' ')[0];

    List<Map<String, dynamic>> studentsList = _filteredStudents.map((student) {
      return {
        "AttId": student['AttdId'] ?? '',
        "ProgramId": student['ProgramId'] ?? '',
        "BranchId": student['BranchId'] ?? '',
        "SemId": student['SemId'] ?? '',
        "SectionId": student['SectionId'] ?? '',
        "CourseId": student['CourseId'] ?? '',
        "Period": student['Period'].toString(),
        "StudentId": student['StudentId'] ?? '',
        "Attended": student['Attendance'] == 1 ? 1 : 2,
      };
    }).toList();

    final Map<String, dynamic> requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "1099",
      "Date": formattedDate,
      "UserId": "1",
      "SaveFacultyWiseAttendenceTableVariable": studentsList,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Attendance data saved successfully!');
        _showToast('Attendance data saved successfully!'); // Show success toast
      } else {
        print('Failed to save data: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showToast('Failed to save data.'); // Show failure toast
      }
    } catch (e) {
      print('Error: $e');
      _showToast('An error occurred while saving data.'); // Show error toast
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0, // Font size
    );
  }

  void _setAllPresent() {
    setState(() {
      for (var student in _filteredStudents) {
        student['Attendance'] = 1 ?? ''; // Set attendance to present
      }
    });
  }

  void _setAllAbsent() {
    setState(() {
      for (var student in _filteredStudents) {
        student['Attendance'] = 2 ?? ''; // Set attendance to absent
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int presentCount =
        _filteredStudents.where((student) => student['Attendance'] == 1).length;
    int absentCount = _filteredStudents.length - presentCount;

    // Safely access the 'Posted' field and provide a default value if null

    return
      Scaffold(
        appBar: AppBar(
          title: Text('Attendance Screen'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDateText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6.0,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        width: double.maxFinite,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            hint: Text(
                              'Pick a Date to Select Period',
                              style: TextStyle(color: Colors.white),
                            ),
                            dropdownColor: Colors.blue,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                            onChanged: _onPeriodSelected,
                            items: _periods.map((period) {
                              return DropdownMenuItem<String>(
                                value: period,
                                child: Text(
                                  period,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedDateText != 'Pick a date' && _selectedPeriod != null)
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _createChartData(),
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                                startDegreeOffset: 90,
                              ),
                              swapAnimationDuration: Duration(milliseconds: 2000),
                              swapAnimationCurve: Curves.easeInOut,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Present: $presentCount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Absent: $absentCount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            _periodData[_selectedPeriod]?['Posted'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _filteredStudents = _students.where((student) {
                                  return student['HallticketNumber']
                                      .toString()
                                      .contains(value) ||
                                      student['StudentName']
                                          .toString()
                                          .toLowerCase()
                                          .contains(value.toLowerCase());
                                }).toList();
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _filteredStudents =
                                        _students; // Reset to show all students
                                  });
                                },
                              )
                                  : null,
                              labelText: 'Search Students',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _setAllPresent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text(
                                  'Mark All Present',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _setAllAbsent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  'Mark All Absent',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List<Widget>.generate(
                                  _filteredStudents.length,
                                      (index) {
                                    final student = _filteredStudents[index];
                                    final isPresent = student['Attendance'] == 1;

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12.0),
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student['HallticketNumber'] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  student['StudentName'],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _toggleAttendance(index),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0, horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                color: isPresent
                                                    ? Colors.green.withOpacity(0.2)
                                                    : Colors.red.withOpacity(0.2),
                                                borderRadius:
                                                BorderRadius.circular(12.0),
                                              ),
                                              child: Text(
                                                isPresent ? 'Present' : 'Absent',
                                                style: TextStyle(
                                                  color: isPresent
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: _students.isNotEmpty
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 220,
              child: FloatingActionButton(
                onPressed: _showPreviewDialog,
                backgroundColor: Colors.blue,
                tooltip: 'Preview Attendance',
                child: Text(
                  "Preview Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
            : null,
      );

  }
}
