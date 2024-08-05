import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'StudentDashboard.dart';

class HostelSelector extends StatefulWidget {
  @override
  _HostelSelectorState createState() => _HostelSelectorState();
}

class _HostelSelectorState extends State<HostelSelector> {
  int? selectedHostelId;
  int? selectedRoomTypeId;
  int? selectedRoomId;
  List<int> selectedItemIndices = []; // Track multiple selected indices
  late Future<Map<String, dynamic>> hostelDataFuture;
  List<dynamic> mainDisplayList = [];
  List<Map<String, dynamic>> allottedBedsDisplayList = [];

  @override
  void initState() {
    super.initState();
    hostelDataFuture = fetchHostelData();
  }

  Future<Map<String, dynamic>> fetchHostelData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    String photo = prefs.getString('photo') ?? '';
    String imagePath = prefs.getString('imagePath') ?? '';
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String password = prefs.getString('password') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegename = prefs.getString('collegename') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String groupUserId = prefs.getString('groupUserId') ?? '';
    String hostelUserId = prefs.getString('hostelUserId') ?? '';
    String transportUserId = prefs.getString('transportUserId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';
    String empId = prefs.getString('empId') ?? '';
    String databaseCode = prefs.getString('databaseCode') ?? '';
    String description = prefs.getString('description') ?? '';
    String dateDifference = prefs.getString('dateDifference') ?? '';
    String userType = prefs.getString('userType') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    String finYear = prefs.getString('finYear') ?? '';
    String email = prefs.getString('email') ?? '';
    String studentStatus = prefs.getString('studentStatus') ?? '';
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCode,
        "ColCode": colCode,
        "AcYear": acYear,
        "UserTypeName": "STUDENT",
        "RegistrationDate": "",
        // "StudentId": "1681",
        "StudentId": studId,
        "HostelId": "0",
        "RoomTypeId": "0",
        "RoomId": "0"
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  void printAllottedBedsDisplayList(List allottedBedsDisplayList) {
    for (var entry in allottedBedsDisplayList) {
      print('Hostel Name: ${entry["hotselName"]}');
      print('Hall Ticket No: ${entry["hallticketNo"]}');
      print('Program Short Name: ${entry["programShortName"]}');
      print('Branch Code: ${entry["branchCode"]}');
      print('Semester: ${entry["semester"]}');
      print('Block Name: ${entry["blockName"]}');
      print('Room Number: ${entry["roomNumber"]}');
      print('Registration Date: ${entry["registrationDate"]}');
      print('User Registered By: ${entry["userRegisteredBy"]}');
      print('User Type Name: ${entry["userTypeName"]}');
      print(''); // Print an empty line for better readability between entries
    }
  }

// Call this function with your allottedBedsDisplayList data

  Future<void> fetchFilteredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    String photo = prefs.getString('photo') ?? '';
    String imagePath = prefs.getString('imagePath') ?? '';
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String password = prefs.getString('password') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegename = prefs.getString('collegename') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String groupUserId = prefs.getString('groupUserId') ?? '';
    String hostelUserId = prefs.getString('hostelUserId') ?? '';
    String transportUserId = prefs.getString('transportUserId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';
    String empId = prefs.getString('empId') ?? '';
    String databaseCode = prefs.getString('databaseCode') ?? '';
    String description = prefs.getString('description') ?? '';
    String dateDifference = prefs.getString('dateDifference') ?? '';
    String userType = prefs.getString('userType') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    String finYear = prefs.getString('finYear') ?? '';
    String email = prefs.getString('email') ?? '';
    String studentStatus = prefs.getString('studentStatus') ?? '';
    if (selectedHostelId == null ||
        selectedRoomTypeId == null ||
        selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select hostel, room type, and room number')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCode,
        "ColCode": colCode,
        "AcYear": acYear,
        "UserTypeName": "STUDENT",
        "RegistrationDate": "",
        "StudentId": studId,
        // "StudentId": "1642",
        "HostelId": selectedHostelId.toString(),
        "RoomTypeId": selectedRoomTypeId.toString(),
        "RoomId": selectedRoomId.toString()
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      if (data['mainDisplayList'] == null) {
        // Handle the situation where there is no vacancy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'No data available')),
        );
        setState(() {
          mainDisplayList = []; // Clear the mainDisplayList
        });
      } else {
        if (data['allottedBedsDisplayList'] != null) {
          setState(() {
            allottedBedsDisplayList = List<Map<String, dynamic>>.from(
              data['allottedBedsDisplayList'],
            );
          });
        }
        if (data['allottedBedsDisplayList'] != null) {
          List allottedBedsDisplayList = data['allottedBedsDisplayList'];
          for (var entry in allottedBedsDisplayList) {
            print('Hostel Name: ${entry["hotselName"]}');
            print('Hall Ticket No: ${entry["hallticketNo"]}');
            print('Program Short Name: ${entry["programShortName"]}');
            print('Branch Code: ${entry["branchCode"]}');
            print('Semester: ${entry["semester"]}');
            print('Block Name: ${entry["blockName"]}');
            print('Room Number: ${entry["roomNumber"]}');
            print('Registration Date: ${entry["registrationDate"]}');
            print('User Registered: ${entry["userRegisteredBy"]}');
            print('User Type : ${entry["userTypeName"]}');
            print(
                ''); // Print an empty line for better readability between entries
          }
        }
        setState(() {
          mainDisplayList = data['mainDisplayList'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch filtered data')),
      );
    }
  }

  Future<void> saveRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    String photo = prefs.getString('photo') ?? '';
    String imagePath = prefs.getString('imagePath') ?? '';
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String password = prefs.getString('password') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegename = prefs.getString('collegename') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String groupUserId = prefs.getString('groupUserId') ?? '';
    String hostelUserId = prefs.getString('hostelUserId') ?? '';
    String transportUserId = prefs.getString('transportUserId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';
    String empId = prefs.getString('empId') ?? '';
    String databaseCode = prefs.getString('databaseCode') ?? '';
    String description = prefs.getString('description') ?? '';
    String dateDifference = prefs.getString('dateDifference') ?? '';
    String userType = prefs.getString('userType') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    String finYear = prefs.getString('finYear') ?? '';
    String email = prefs.getString('email') ?? '';
    String studentStatus = prefs.getString('studentStatus') ?? '';
    String registrationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Map<String, dynamic>> selectedRooms = selectedItemIndices.map((index) {
      final room = mainDisplayList[index];
      return {
        "FeeId": room['feeId'].toString(),
        "Frequency": room['frequency'].toString(),
        "Installement": room['installement']
      };
    }).toList();

    final requestBody = jsonEncode({
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": "1",
      "StudentId": studId,
      "HostelId": selectedHostelId,
      "UserTypeName": "STUDENT",
      "AcYear": acYear,
      "StartDate": "", // Check if this field needs a value
      "RegistrationDate":registrationDate,
      "RoomTypeId": selectedRoomTypeId?.toString() ?? "",
      "RoomId": selectedRoomId?.toString() ?? "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": adminUserId,
      "HostelSaveRegularStudentRegistrationWithFeestablevariable":
          selectedRooms,
    });

    // Print the request body for debugging
    print('Request Body: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/HostelSaveRegularStudentRegistrationWithFees'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      // Print the response body for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      final message = data['message'] ?? 'No message available';
      final List<dynamic> feesList =
          data['regularStudentRegistrationWithFeesList'] ?? [];
      if (response.statusCode == 200) {
        if (feesList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration saved successfully')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentDashboard()),
          );
        }
      } else {
        // Display the message in case of a bad request or other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      // Handle potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void showPreviewDialog() {
    // Get the roomTypeName from the first selected item
    final roomTypeName = selectedItemIndices.isNotEmpty
        ? mainDisplayList[selectedItemIndices.first]['roomTypeName']
        : 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the roomTypeName as a heading
                if (roomTypeName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 16),
                    child: Text(
                      '$roomTypeName',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ...selectedItemIndices.map((index) {
                  final room = mainDisplayList[index];
                  return ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${room['feeName']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Total Fee Amount: ${room['totalFeeAmount']}'),
                        Text('Frequency: ${room['frequency']}'),
                        Text('Installments: ${room['installement']}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.of(context).pop();
                saveRegistration();
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isFetchButtonEnabled = selectedHostelId != null &&
        selectedRoomTypeId != null &&
        selectedRoomId != null;

    // Check if there are any pre-selected items
    bool hasPreSelectedItems =
        mainDisplayList.any((room) => room['checked'] == 1);

    // Update the preview button visibility based on pre-selected items or user-selected items
    bool isPreviewButtonVisible =
        hasPreSelectedItems || selectedItemIndices.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hostel Registration'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: hostelDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final hostels = data['hostelList'] as List;
          final roomTypes = data['roomTypedropdownList'] as List;
          final vacancyRooms = data['vaccancyRoomsdropdownList'] as List;

          final filteredRoomTypes = selectedHostelId != null
              ? roomTypes
                  .where((rt) => rt['hostelId'] == selectedHostelId)
                  .toList()
              : [];
          final filteredRooms = selectedRoomTypeId != null
              ? vacancyRooms
                  .where((r) =>
                      r['hostelId'] == selectedHostelId &&
                      r['roomTypeId'] == selectedRoomTypeId)
                  .toList()
              : [];

          // Extract room details for the container at the top
          final roomDetails =
              mainDisplayList.isNotEmpty ? mainDisplayList.first : null;
          final roomCapacity =
              roomDetails != null ? roomDetails['roomCapacity'] : 'N/A';
          final allottedBeds =
              roomDetails != null ? roomDetails['allottedBeds'] : 'N/A';
          final availableBeds =
              roomDetails != null ? roomDetails['availableBeds'] : 'N/A';

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8.0),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Select Hostel',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    value: selectedHostelId,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedHostelId = newValue;
                        selectedRoomTypeId = null;
                        selectedRoomId = null;
                        selectedItemIndices.clear(); // Clear selected items
                      });
                    },
                    items: hostels.map<DropdownMenuItem<int>>((hostel) {
                      return DropdownMenuItem<int>(
                        value: hostel['hostelId'],
                        child: Text(hostel['hostelName']),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                if (selectedHostelId != null)
                  Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Room Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: selectedRoomTypeId,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedRoomTypeId = newValue;
                          selectedRoomId = null;
                          selectedItemIndices.clear(); // Clear selected items
                        });
                      },
                      items: filteredRoomTypes
                          .map<DropdownMenuItem<int>>((roomType) {
                        return DropdownMenuItem<int>(
                          value: roomType['roomTypeId'],
                          child: Text(roomType['roomTypeName']),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 16.0),
                if (selectedRoomTypeId != null)
                  Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Room Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                      value: selectedRoomId,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedRoomId = newValue;
                          selectedItemIndices.clear(); // Clear selected items
                        });
                      },
                      items: filteredRooms.map<DropdownMenuItem<int>>((room) {
                        return DropdownMenuItem<int>(
                          value: room['roomId'],
                          child: Text(room['roomNumber']),
                        );
                      }).toList(),
                    ),
                  ),
                SizedBox(height: 16.0),
                Container(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isFetchButtonEnabled ? fetchFilteredData : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Set the background color to blue
                    ),
                    child: Text(
                      'Fetch Data',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (roomDetails != null)
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Room Capacity: $roomCapacity'),
                        Row(
                          children: [
                            Text('Allotted Beds: $allottedBeds'),
                            if (allottedBeds != 0)
                              IconButton(
                                onPressed: () => _showAllottedBedsDialog(),
                                icon: Icon(Icons.info_sharp),
                              ),
                          ],
                        ),

                        Text('Available Beds: $availableBeds'),
                      ],
                    ),
                  ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: mainDisplayList.length,
                    itemBuilder: (context, index) {
                      final room = mainDisplayList[index];
                      final isSelected = selectedItemIndices.contains(index) ||
                          room['checked'] == 1;

                      if (room['checked'] == 1 &&
                          !selectedItemIndices.contains(index)) {
                        selectedItemIndices.add(index);
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (room['checked'] != 1) {
                              if (isSelected) {
                                selectedItemIndices.remove(index);
                              } else {
                                selectedItemIndices.add(index);
                              }
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                          ),
                          child: Container(
                            margin: EdgeInsets.all(0.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              title: Text(
                                'Fee Name: ${room['feeName'] ?? 'N/A'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Total Fee Amount: ${room['totalFeeAmount']}'),
                                  Text('Frequency: ${room['frequency']}'),
                                  Text('Installments: ${room['installement']}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: isPreviewButtonVisible
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220, // Set the width here
                  child: FloatingActionButton(
                    onPressed: showPreviewDialog,
                    child: Text(
                      "Preview Selection",
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                    tooltip: 'Preview Selection',
                    backgroundColor:
                        Colors.blue, // Set the background color here
                  ),
                ),
              ],
            )
          : null,
    );
  }

  void _showAllottedBedsDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Allotted Beds Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),

                    SizedBox(
                      height: 500, // Adjust the height as needed
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allottedBedsDisplayList.length,
                        itemBuilder: (context, index) {
                          final bedDetail = allottedBedsDisplayList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.circular(15)),

                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    '${bedDetail["hotselName"] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Hall Ticket No: ${bedDetail["hallticketNo"] ?? 'N/A'}'),
                                      Text('Program: ${bedDetail["programShortName"] ?? 'N/A'}'),
                                      Text('Branch: ${bedDetail["branchCode"] ?? 'N/A'}'),
                                      Text('Semester: ${bedDetail["semester"] ?? 'N/A'}'),
                                      Text('Block: ${bedDetail["blockName"] ?? 'N/A'}'),
                                      Text('Room Number: ${bedDetail["roomNumber"] ?? 'N/A'}'),
                                      Text('Registration Date: ${bedDetail["registrationDate"] ?? 'N/A'}'),
                                      Text('User Registered: ${bedDetail["userRegistered"] ?? 'N/A'}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    TextButton(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            child: child,
          ),
        );
      },
    );
  }

}
