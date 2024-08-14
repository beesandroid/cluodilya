import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ClassRequest extends StatefulWidget {
  const ClassRequest({super.key});

  @override
  State<ClassRequest> createState() => _ClassRequestState();
}

class _ClassRequestState extends State<ClassRequest> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> classList = [];
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
      _callClassRequestAPI();
    }
  }

  // Function to call the Class Request API
  Future<void> _callClassRequestAPI() async {
    if (selectedDate == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    // Request body for "class" flag
    Map<String, dynamic> requestBodyClass = {
      "grpCode": "BEES",
      "colCode": "0001",
      "collegeId": 1,
      "studentId": 1242,
      "courseId": 0,
      "date": formattedDate,
      "periods": "",
      "flag": "class",
      "course": "",
      "employee": "",
      "faculty": 0,
      "topicName": "",
      "message": "",
      "description": ""
    };

    try {
      final responseClass = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AttendanceRequest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBodyClass),
      );

      if (responseClass.statusCode == 200) {
        List<Map<String, dynamic>> classData = [];
        Map<String, dynamic> dataClass = jsonDecode(responseClass.body) as Map<String, dynamic>;

        classData.addAll((dataClass['attendanceRequestdisplayList'] as List)
            .map((item) => (item as Map<String, dynamic>)..['originalFlag'] = 'class'..['selected'] = false)
            .toList());

        setState(() {
          classList = classData;
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
    List<Map<String, dynamic>> saveClassRequestTableVariables = [];

    for (var item in classList) {
      if (item['selected'] as bool) {
        var description = descriptions[item.hashCode] ?? '';
        saveClassRequestTableVariables.add({
          "courseId": item['courseId'] ?? 0,
          "description": description,
          "employeeId": item['faculty'] ?? 0,
          "topicId": 0,
          "period": item['periods'],
        });
      }
    }

    Map<String, dynamic> requestBody =
    {
      "grpCode": "BEES",
    "colCode": "0001",
    "collegeId": 1,
    "studentId": 1242,
    "id": 0,
    "studentName": "",
    "requestDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    "date": selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "",
    "courseId": 0,
    "courseName": "",
    "period": "",
    "employeeId": 0,
    "employeeName": "",
    "description": "",
    "status": "",
    "createdBy": 0,
    "createdDate": "",
    "modifiedBy": 0,
    "modifiedDate": "",
    "loginIpAddress": "",
    "loginSystemName": "",
    "flag": "CREATE",
    "requestType": "",

    "saveClassRequestTableVariables": saveClassRequestTableVariables,

    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveAttendanceRequest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved successfully')),
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
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.calendar_month, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: classList.isEmpty
                  ? Center(child: Text('Select Date'))
                  : ListView.builder(
                itemCount: classList.length,
                itemBuilder: (context, index) {
                  var item = classList[index];
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
                        color: isSelected ? Colors.blue[300] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
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
                                  'Faculty ID: ${item['faculty'] ?? 'Unknown Faculty'}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ), Text(
                                  'employee: ${item['employee'] ?? 'Unknown Faculty'}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),Text(
                                  'Period: ${item['periods'] ?? 'Unknown Faculty'}',
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
