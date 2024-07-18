import 'package:cloudilya/staff/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Picker and Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AttendanceScreen(),
    );
  }
}

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
    _searchController.addListener(_filterStudents);
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
      _students[index]['Attendance'] =
          _students[index]['Attendance'] == 1 ? 2 : 1;
      _filterStudents(); // Filter list after changing attendance
    });
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        final name = student['StudentName'].toLowerCase();
        return name.contains(query);
      }).toList();
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

  Future<void> _showPreviewDialog() async {
    final presentStudents = _filteredStudents
        .where((student) => student['Attendance'] == 1)
        .toList();
    final absentStudents = _filteredStudents
        .where((student) => student['Attendance'] == 2)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 25,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Preview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.0),
                // Present Students Section
                if (presentStudents.isNotEmpty) ...[
                  Text(
                    'Present Students:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ...presentStudents.map((student) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              student['StudentName'],
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              'P',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ],
                // Absent Students Section
                if (absentStudents.isNotEmpty) ...[
                  Text(
                    'Absent Students:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ...absentStudents.map((student) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              student['StudentName'],
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              'A',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 16.0),
                ],
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _saveAttendance(); // Save attendance when confirmed
                      },
                      child: Text('Save'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showToast('Operation cancelled.');
                      },
                      child: Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
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

              Container(
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      hint: Text('Select Period'),
                      onChanged: _onPeriodSelected,
                      items: _periods.map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                    ),


                    Container(width: 300,
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _createChartData(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          startDegreeOffset: 90,
                        ),
                        swapAnimationDuration: Duration(milliseconds: 1500),
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
                      decoration: InputDecoration(
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
                                  border: Border.all(color: Colors.grey.shade300),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['StudentName'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            student['HallticketNumber'] ?? '',
                                            style: TextStyle(color: Colors.grey),
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
                                          borderRadius: BorderRadius.circular(12.0),
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
              )
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 220,
              child: FloatingActionButton(
                onPressed: _showPreviewDialog,
                backgroundColor: Colors.blue,
                tooltip: 'Preview Attendance',
                child: Text(
                  "SAVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
;
  }
}
