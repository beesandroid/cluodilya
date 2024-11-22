import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class StudentTimeTableScreen extends StatefulWidget {
  const StudentTimeTableScreen({super.key});

  @override
  State<StudentTimeTableScreen> createState() => _StudentTimeTableScreenState();
}

class _StudentTimeTableScreenState extends State<StudentTimeTableScreen> {
  Map<String, List<dynamic>> _timeTableData = {};
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now(); // Set to today's date

  @override
  void initState() {
    super.initState();
    _fetchTimeTable(
        date: _selectedDate
            .toIso8601String()
            .split('T')
            .first); // Fetch timetable for today
  }

  Future<void> _fetchTimeTable({String date = ''}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/StudentSelfService/StudentTimeTableDisplay';
    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": collegeId,
      "StudentId": studId,
      "Date": date,
    };
    print(requestBody);
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      final List<dynamic> rawTimeTableData =
          data['studentTimeTableDisplayList'] ?? [];
      final groupedData = <String, List<dynamic>>{};

      if (rawTimeTableData is List) {
        for (var item in rawTimeTableData) {
          final date = item['date'] ?? 'Unknown Date';
          if (groupedData.containsKey(date)) {
            groupedData[date]!.add(item);
          } else {
            groupedData[date] = [item];
          }
        }

        setState(() {
          _timeTableData = groupedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Unexpected data structure');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load timetable');
    }
  }

  Widget _buildTimeTable() {
    return ListView.builder(
      itemCount: _timeTableData.keys.length,
      itemBuilder: (context, index) {
        final date = _timeTableData.keys.elementAt(index);
        final dayDataList = _timeTableData[date] ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Heading with bold gradient text
              Text(
                date,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        Colors.blue.shade900,
                        Colors.blue.shade400,
                      ],
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),

              SizedBox(height: 8),
              // Timetable table with glass effect and vibrant colors
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                      offset: Offset(3, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Table(
                      border: TableBorder(
                        horizontalInside: BorderSide(
                            color: Colors.white.withOpacity(0.4), width: 0.5),
                        verticalInside: BorderSide.none,
                      ),
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(4),
                      },
                      children: [
                        // Header row with vibrant gradient background
                        TableRow(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade900,
                                Colors.blue.shade400,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Period',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Subject',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Table Content Rows with improved text visibility
                        for (var dayData in dayDataList) ...[
                          for (int i = 1; i <= 7; i++)
                            if (dayData.containsKey('period$i'))
                              TableRow(
                                decoration: BoxDecoration(color: Colors.white),
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 8.0),
                                      child: Text(
                                        'Period $i',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 8.0),
                                      child: Text(
                                        dayData['period$i'] ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xFF141E30),
                //     Color(0xFF243B55),
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
                ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                child: TableCalendar(
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black),
                    weekendStyle: TextStyle(color: Colors.redAccent),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle:
                        TextStyle(color: Colors.black, fontSize: 16),
                    formatButtonTextStyle: TextStyle(color: Colors.black),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.black),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.black),
                  ),
                  focusedDay: _selectedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _isLoading = true;
                      _fetchTimeTable(
                          date: selectedDay.toIso8601String().split('T').first);
                    });
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: Colors.black))
                    : _timeTableData.isNotEmpty
                        ? _buildTimeTable()
                        : Center(
                            child: Text('No Time-Table on this day',
                                style: TextStyle(color: Colors.black))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
