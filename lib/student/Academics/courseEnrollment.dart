import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentEnrollment extends StatefulWidget {
  const StudentEnrollment({super.key});

  @override
  State<StudentEnrollment> createState() => _StudentEnrollmentState();
}

class _StudentEnrollmentState extends State<StudentEnrollment> {
  List<dynamic> _courseList = [];
  int? _selectedCategoryId;
  int? _selectedCourseId;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchEnrollmentData();
  }

  Future<void> _fetchEnrollmentData() async {
    final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentSelfService_CourseEnrollment';
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudCourseId": "0",
      "StudentId": "1242",
      "CourseId": "0",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "VIEW"
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      setState(() {
        if (data['savingOfStudentSelectionList'].isEmpty) {
          _message = data['message'] ?? 'No courses available';
        } else {
          _courseList = data['savingOfStudentSelectionList'];
          _message = '';
        }
      });
    } else {
      print('Failed to load data');
    }
  }

  Future<void> _showAddDialog() async {
    final courseCategoryResponse = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CourseDropdowForEnrollment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "BEES",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "1647"
      }),
    );

    if (courseCategoryResponse.statusCode == 200) {
      final data = jsonDecode(courseCategoryResponse.body);
      final categories = data['courseDropdowForEnrollmetList'];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(backgroundColor: Colors.white,
            title: Text('Select Course Category', style: TextStyle(color: Colors.black)),
            content: DropdownButtonFormField<int>(
              items: categories.map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['courseCategoryId'] as int?,
                  child: Text(category['courseCategoryName'] as String, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedCategoryId = value;
                });
                Navigator.pop(context);
                if (value != null) {
                  _fetchCoursesForCategory(value);
                }
              },
              hint: Text('Select a category', style: TextStyle(color: Colors.black)),
              dropdownColor: Colors.blue,
            ),
          );
        },
      );
    } else {
      print('Failed to load course categories');
    }
  }

  Future<void> _fetchCoursesForCategory(int categoryId) async {
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudentId": "1647",
      "CourseCategoryId": categoryId.toString(),
      "SemId": 0
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    final courseResponse = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CourseDropDownForStudentSelection'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Response Body: ${courseResponse.body}');

    if (courseResponse.statusCode == 200) {
      final data = jsonDecode(courseResponse.body);
      final courses = data['courseDropDownForStudentSelectionList'];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Select Course', style: TextStyle(color: Colors.black)),
            content: Container(
              width: double.maxFinite, // Make the container width flexible
              child: DropdownButtonFormField<int>(
                items: courses.map<DropdownMenuItem<int>>((course) {
                  return DropdownMenuItem<int>(
                    value: course['courseId'] as int?,
                    child: Text(
                      course['courseName'] as String,
                      style: TextStyle(color: Colors.white), // Adjust text color
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedCourseId = value;
                  });
                  Navigator.pop(context);
                  if (value != null) {
                    _enrollInCourse(value);
                  }
                },
                hint: Text('Select a course', style: TextStyle(color: Colors.black)),
                dropdownColor: Colors.blue,
                isExpanded: true, // Ensure the dropdown uses the full width
              ),
            ),
          );
        },
      );

    } else {
      print('Failed to load courses');
    }
  }

  Future<void> _enrollInCourse(int courseId) async {
    final enrollResponse = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentSelfService_CourseEnrollment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudCourseId": "8",
        "StudentId": "1647",
        "CourseId": courseId.toString(),
        "UserId": "1",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "CREATE"
      }),
    );

    final data = jsonDecode(enrollResponse.body);
    final message = data['message'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.isNotEmpty ? message : 'Enrolled successfully'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('Course Enrollment',style: TextStyle(fontWeight: FontWeight.bold),),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(

        ),
        child: Column(
          children: [
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _message,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: _courseList.isEmpty
                  ? Center(
                child: Text(
                  'No courses available',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: _courseList.length,
                itemBuilder: (context, index) {
                  final course = _courseList[index];
                  return Card(color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        course['courseName'],
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Type: ${course['courseType']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: Text(
                        'Category: ${course['courseCategoryName']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              )

            ),
            Container(width: 220,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showAddDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Add', style: TextStyle(fontSize: 18,color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
