import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceRequest extends StatefulWidget {
  const AttendanceRequest({super.key});

  @override
  State<AttendanceRequest> createState() => _AttendanceRequestState();
}

class _AttendanceRequestState extends State<AttendanceRequest> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> attendanceList = [];
  Map<int, String> descriptions = {};

  @override
  void initState() {
    super.initState();
  }

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      // Call the APIs after the date is selected
      _callAttendanceAPI();
    }
  }

  // Function to call the Attendance API
  Future<void> _callAttendanceAPI() async {
    if (selectedDate == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // Request body for "attendance" flag
    Map<String, dynamic> requestBodyAttendance = {
      "grpCode": "BEESdev",
      "colCode": "0001",
      "collegeId": 1,
      "studentId": 1242,
      "courseId": 0,
      "date": formattedDate,
      "periods": "",
      "flag": "attendance",
      "course": "",
      "employee": "",
      "faculty": 0,
      "topicName": "",
      "message": "",
      "description": ""
    };

    try {
      final responseAttendance = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AttendanceRequest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBodyAttendance),
      );

      if (responseAttendance.statusCode == 200) {
        print(responseAttendance);
        List<Map<String, dynamic>> attendanceData = [];
        Map<String, dynamic> dataAttendance = jsonDecode(responseAttendance.body) as Map<String, dynamic>;

        attendanceData.addAll((dataAttendance['attendanceRequestdisplayList'] as List)
            .map((item) => (item as Map<String, dynamic>)..['originalFlag'] = 'attendance'..['selected'] = false)
            .toList());

        setState(() {
          attendanceList = attendanceData;
        });
      } else {
        // Handle API error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Function to save selected items
  Future<void> _saveSelectedItems() async {
    List<Map<String, dynamic>> saveAttendanceRequestTableVariables = [];

    for (var item in attendanceList) {
      if (item['selected'] as bool) {
        var description = descriptions[item.hashCode] ?? '';
        saveAttendanceRequestTableVariables.add({
          "courseId": item['courseId'] ?? 0,
          "period": item['periods'] ?? "",
          "employeeId": item['faculty'] ?? 0,
          "description": description,
        });
      }
    }

    Map<String, dynamic> requestBody = {
      "grpCode": "BEESdev",
      "colCode": "0001",
      "collegeId": 1,
      "studentId": 1242,


      "requestDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "date": selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "",
      "id": 0,

      "loginIpAddress": "",
      "loginSystemName": "",
      "flag": "CREATE",

      "saveAttendanceRequestTableVariables": saveAttendanceRequestTableVariables,

    };

    try {
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveAttendanceRequest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = jsonDecode(response.body);
        String message = responseBody['message'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.white),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Calendar icon
                  SizedBox(width: 8), // Space between the icon and text
                  Text(
                    selectedDate == null
                        ? 'Select Date'
                        : 'Selected Date : ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                ],
              ),
            )
            ,
            SizedBox(height: 20),
            Expanded(
              child: attendanceList.isEmpty
                  ? Center(child: Text('Select Date',style: TextStyle(fontWeight: FontWeight.bold),))
                  : ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  var item = attendanceList[index];
                  bool isSelected = item['selected'] as bool;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item['selected'] = !isSelected;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red[300] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              item['course'] ?? 'Unknown Course',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['employee'] ?? 'Unknown Employee',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  'Faculty ID: ${item['faculty'] ?? 'Unknown Faculty'}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  'Periods: ${item['periods'] ?? 'Unknown Periods'}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                if(item['message']!=null)
                                  Text(
                                    'Message: ${item['message'] ?? 'Unknown Faculty'}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                              ],
                            ),

                            selected: isSelected,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    descriptions[item.hashCode] = value;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if(selectedDate!=null)
              ElevatedButton(
                onPressed: _saveSelectedItems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white),
                  ),
                ),
                child: Text(
                  'Save Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}