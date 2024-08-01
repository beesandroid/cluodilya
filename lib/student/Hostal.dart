import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    hostelDataFuture = fetchHostelData();
  }

  Future<Map<String, dynamic>> fetchHostelData() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "AcYear": "2024 - 2025",
        "UserTypeName": "STUDENT",
        "RegistrationDate": "",
        "StudentId": "1642",
        // "StudentId": "1680",
        "HostelId": "0",
        "RoomTypeId": "0",
        "RoomId": "0"
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchFilteredData() async {
    if (selectedHostelId == null || selectedRoomTypeId == null || selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select hostel, room type, and room number')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "AcYear": "2024 - 2025",
        "UserTypeName": "STUDENT",
        "RegistrationDate": "",
        "StudentId": "1642",
        "HostelId": selectedHostelId.toString(),
        "RoomTypeId": selectedRoomTypeId.toString(),
        "RoomId": selectedRoomId.toString()
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['mainDisplayList'] == null) {
        // Handle the situation where there is no vacancy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'No data available')),
        );
        setState(() {
          mainDisplayList = []; // Clear the mainDisplayList
        });
      } else {
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
    List<Map<String, dynamic>> selectedRooms = selectedItemIndices.map((index) {
      final room = mainDisplayList[index];
      return {
        "FeeId": room['feeId'].toString(),
        "Frequency": room['frequency'].toString(),
        "Installement": room['installement']
      };
    }).toList();

    final requestBody = jsonEncode({
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudentId": "1642",
      "HostelId": "1",
      "UserTypeName": "STUDENT",
      "AcYear": "2024 - 2025",
      "StartDate": "", // Check if this field needs a value
      "RegistrationDate": "2024-07-31",
      "RoomTypeId": selectedRoomTypeId?.toString() ?? "",
      "RoomId": selectedRoomId?.toString() ?? "",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": "1",
      "HostelSaveRegularStudentRegistrationWithFeestablevariable": selectedRooms,
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

      // Extract the message from the response
      final message = data['message'] ?? 'No message available';
      final List<
          dynamic> feesList = data['regularStudentRegistrationWithFeesList'] ??
          [];

      // Check if the fees list is empty and display the message
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
            MaterialPageRoute(builder: (context) => HostelSelector()),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ...selectedItemIndices.map((index) {
                  final room = mainDisplayList[index];
                  return ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${room['feeName']}',style: TextStyle(fontWeight: FontWeight.bold),),
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
    bool hasPreSelectedItems = mainDisplayList.any((room) =>
    room['checked'] == 1);

    // Update the preview button visibility based on pre-selected items or user-selected items
    bool isPreviewButtonVisible = hasPreSelectedItems ||
        selectedItemIndices.isNotEmpty;

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
              ? roomTypes.where((rt) => rt['hostelId'] == selectedHostelId)
              .toList()
              : [];
          final filteredRooms = selectedRoomTypeId != null
              ? vacancyRooms.where((r) =>
          r['hostelId'] == selectedHostelId &&
              r['roomTypeId'] == selectedRoomTypeId).toList()
              : [];

          // Extract room details for the container at the top
          final roomDetails = mainDisplayList.isNotEmpty
              ? mainDisplayList.first
              : null;
          final roomCapacity = roomDetails != null
              ? roomDetails['roomCapacity']
              : 'N/A';
          final allottedBeds = roomDetails != null
              ? roomDetails['allottedBeds']
              : 'N/A';
          final availableBeds = roomDetails != null
              ? roomDetails['availableBeds']
              : 'N/A';

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
                      items: filteredRoomTypes.map<DropdownMenuItem<int>>((
                          roomType) {
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
                      backgroundColor: Colors
                          .blue, // Set the background color to blue
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
                        Text('Allotted Beds: $allottedBeds'),
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
              backgroundColor: Colors.blue, // Set the background color here
            ),
          ),
        ],
      )
          : null,
    );
  }
}