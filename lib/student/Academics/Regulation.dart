import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Regulation extends StatefulWidget {
  const Regulation({super.key});

  @override
  State<Regulation> createState() => _RegulationState();
}

class _RegulationState extends State<Regulation> {
  late Future<Map<String, dynamic>> _futureData;
  String _selectedSemester = "";

  @override
  void initState() {
    super.initState();
    _futureData = fetchCurriculumData();
  }

  Future<Map<String, dynamic>> fetchCurriculumData() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CurriculumDataDisplay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "BEESdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "1400",
        "SemId": 0
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);

    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: const Text(
          'Curriculum Regulation',
          style: TextStyle(

            fontWeight: FontWeight.bold,
            fontSize: 20,color: Colors.white
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          final curriculumList = snapshot.data!['curriculumDisplayList'] as List<dynamic>;
          final uniqueSemesters = curriculumList
              .map((e) => e['semester'])
              .toSet()
              .toList();

          final filteredList = _selectedSemester.isEmpty
              ? curriculumList
              : curriculumList.where((e) => e['semester'] == _selectedSemester).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: uniqueSemesters.length,
                    itemBuilder: (context, index) {
                      final semester = uniqueSemesters[index];
                      final isSelected = _selectedSemester == semester;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSemester = isSelected ? "" : semester;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              semester,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text('No courses available for selected semester',style: TextStyle(fontWeight: FontWeight.bold),))
                    : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['courseName'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Semester: ${item['semester']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Category: ${item['courseCategoryName']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Type: ${item['courseType']}',
                                style: TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Credits: ${item['credits']}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
