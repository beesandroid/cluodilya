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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
    _fetchAttendanceData(_selectedDateText, "0"); // Default call with period "0"
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
        _selectedDateText = '${_selectedDate.toLocal()}'.split(' ')[0]; // Update the text
        _selectedPeriod = null;
        _students = [];
        _filteredStudents = [];
        _periods = [];
      });

      String formattedDate = _selectedDateText;
      await _fetchAttendanceData(formattedDate, _selectedPeriod ?? "0");
    }
  }

  Future<void> _fetchAttendanceData(String date, String period) async {
    final String url =
        'https://beessoftware.cloud/CoreAPI/CloudilyaMobileAPP/FacultyDailyAttendanceDisplay';

    final Map<String, dynamic> requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "Date": date,
      "ProgramId": "0",
      "BranchId": "0",
      "SemId": "0",
      "SectionId": "0",
      "EmployeeId": "1099",
      "Period": period, // Use the selected period
      "Flag": "FacultyWise"
    };
    print(requestBody);

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
        final periods = data['FacultyDailyAttendanceDisplayList'][0]['Periods'];
        setState(() {
          _periods = periods.keys.toList();
          _periodData = periods;
          if (_selectedPeriod != null && _periodData.containsKey(_selectedPeriod)) {
            _students = _periodData[_selectedPeriod]['Students'];
            _filteredStudents = _students;
          }
        });
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onPeriodSelected(String? period) {
    setState(() {
      _selectedPeriod = period;
      if (_selectedPeriod != null) {
        _fetchAttendanceData(_selectedDateText, _selectedPeriod!); // Fetch data based on selected period
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final presentCount =
        _filteredStudents.where((student) => student['Attendance'] == 1).length;
    final absentCount = _filteredStudents.length - presentCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Card(
                    elevation: 25,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Text(_selectedDateText),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_periods.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: DropdownButton<String>(
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text('Select a period'),
                                  ),
                                  value: _selectedPeriod,
                                  onChanged: _onPeriodSelected,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  items: _periods.map((String period) {
                                    return DropdownMenuItem<String>(
                                      value: period,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(period),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_students.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 200.0,
                      child: PieChart(
                        PieChartData(
                          sections: _createChartData(),
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event,
                                PieTouchResponse? pieTouchResponse) {
                              // Handle touch events here if needed
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_students.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Present: $presentCount',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                      SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Absent: $absentCount',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Students',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Text(student['StudentName']),
                            trailing: Checkbox(
                              value: student['Attendance'] == 1,
                              onChanged: (_) => _toggleAttendance(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
