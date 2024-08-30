import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTimeTable();
  }

  Future<void> _fetchTimeTable({String date = ''}) async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/StudentSelfService/StudentTimeTableDisplay';
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudentId": "1640",
      "Date": date,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> rawTimeTableData = data['studentTimeTableDisplayList'] ?? [];
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
              Text(
                date,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                  outside: BorderSide.none,
                ),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(4),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Period',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Subject',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var dayData in dayDataList) ...[
                    for (int i = 1; i <= 10; i++)
                      if (dayData.containsKey('period$i'))
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Period $i', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(dayData['period$i'] ?? '', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                  ],
                ],
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
      appBar: AppBar(
        backgroundColor:  Color(0xFF243B55),
        title: const Text('Student Time Table', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF141E30),
                  Color(0xFF243B55),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.redAccent),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white),
                    weekendStyle: TextStyle(color: Colors.redAccent),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  focusedDay: _selectedDate,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _isLoading = true;
                      _fetchTimeTable(date: selectedDay.toIso8601String().split('T').first);
                    });
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : _timeTableData.isNotEmpty
                    ? _buildTimeTable()
                    : Center(child: Text('No timetable data available', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
