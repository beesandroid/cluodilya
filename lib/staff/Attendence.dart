import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

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
  List<String> _topics = []; // To store the list of topics
  List<String> _selectedTopics = [];

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
      "EmployeeId": "1088",
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

  int getPeriodNumber(String selectedPeriod) {
    final RegExp periodRegExp = RegExp(r'period(\d+)');
    final match = periodRegExp.firstMatch(selectedPeriod);

    if (match != null && match.groupCount > 0) {
      return int.parse(match.group(1)!);
    } else {
      throw ArgumentError('Invalid period format');
    }
  }

  Future<void> _fetchAndPrintTopics(String formattedDate) async {
    final String url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/TopicDropDown';

    final Map<String, dynamic> requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "EmployeeId": "1088",
      "Period": "4",
      "Date": formattedDate
    };
    print("Request Body: ${requestBody.toString()}");

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
        print('Response data: $data');

        if (data['topicDropDownList'] != null &&
            data['topicDropDownList'].isNotEmpty) {
          final topicList = data['topicDropDownList'] as List<dynamic>;
          final fetchedTopics = topicList
              .map((topic) => topic['topicName'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();

          setState(() {
            _topics = fetchedTopics;
          });

          print('Fetched Topics: $_topics');
        } else {
          print('No topic data available');
        }
      } else {
        print('Failed to load data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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
      "EmployeeId": "1088",
      "Date": formattedDate,
      "UserId": "1",
      "FacultyWiseAttendenceTableVariable": studentsList,
      "AttendanceTopicTableVariablesListForFaculty": [
        {"Period": "4", "TopicId": _selectedTopics},
      ]
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
  void _onPeriodSelected(String? period) {
    if (period == null) return;

    setState(() {
      _selectedPeriod = period;
    });

    // Fetch data for the selected period
    _fetchAttendanceData(_selectedDateText);
    _fetchAndPrintTopics(_selectedDateText);
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

  void _showPreviewDialog() {
    final totalCount = _filteredStudents.length;
    final presentCount =
        _filteredStudents.where((student) => student['Attendance'] == 1).length;
    final absentCount = totalCount - presentCount;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                // Display total, present, and absent counts
                Text(
                  'Total Students: $totalCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Present: $presentCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Absent: $absentCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300, // Adjust as needed
                  ),
                  child: Column(
                    children: _filteredStudents.map((student) {
                      final isPresent = student['Attendance'] == 1;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                student['StudentName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // Prevent overflow
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

                child: SingleChildScrollView(
                  child: Container(
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
                            width: double.infinity,
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                    child: MultiSelectDialogField<String>(
                      items: _topics.map((topic) => MultiSelectItem<String>(topic, topic)).toList(),
                      title: Text("Select Topics"),
                      selectedColor: Colors.blue,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                      buttonText: Text(
                        "Select Topics",
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                      onConfirm: (results) {
                        setState(() {
                          _selectedTopics = results;
                        });
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        items: _selectedTopics.map((topic) => MultiSelectItem<String>(topic, topic)).toList(),
                        onTap: (value) {
                          setState(() {
                            _selectedTopics.remove(value);
                          });
                        },
                      ),
                    ),
                  ),
                )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              if (_selectedDateText != 'Pick a date' && _selectedPeriod != null)
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
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
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final totalCount = _students?.length ?? 0;
                              final presentCount = _students?.where((student) => student['Attendance'] == 1).length ?? 0;
                              final presentFlex = presentCount;
                              final absentFlex = totalCount - presentFlex;

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: presentFlex,
                                      child: Container(
                                        color: Colors.green,
                                        height: 30.0,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              totalCount > 0 ? '${(presentCount / totalCount * 100).toStringAsFixed(1)}%' : '0%',
                                              style: TextStyle(color: Colors.white, fontSize: 12.0),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: absentFlex,
                                      child: Container(
                                        color: Colors.transparent,
                                        height: 30.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final totalCount = _students?.length ?? 0;
                              final absentCount = totalCount - (_students?.where((student) => student['Attendance'] == 1).length ?? 0);
                              final absentFlex = absentCount;
                              final presentFlex = totalCount - absentFlex;

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: absentFlex,
                                      child: Container(
                                        color: Colors.red,
                                        height: 30.0,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              totalCount > 0 ? '${(absentCount / totalCount * 100).toStringAsFixed(1)}%' : '0%',
                                              style: TextStyle(color: Colors.white, fontSize: 12.0),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: presentFlex,
                                      child: Container(
                                        color: Colors.transparent,
                                        height: 30.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
                          Row(
                            children: [
                              Text(
                                'Present: $presentCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 58.0),
                                child: Text(
                                  'Absent: $absentCount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                  return student['HallticketNumber'].toString().contains(value) ||
                                      student['StudentName'].toString().toLowerCase().contains(value.toLowerCase());
                                }).toList();
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _filteredStudents = _students; // Reset to show all students
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
                                                  student['HallticketNumber'] ?? '',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                ),
                                                Text(
                                                  student['StudentName'],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _toggleAttendance(index),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: Text(
                                                isPresent ? 'Present' : 'Absent',
                                                style: TextStyle(
                                                  color: isPresent ? Colors.green : Colors.red,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Container(
                width: 100,
                child: FloatingActionButton(
                  onPressed: _saveAttendance,
                  backgroundColor: Colors.blue,
                  tooltip: 'Save',
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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
