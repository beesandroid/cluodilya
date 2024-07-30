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
  Set<int> selectedRoomIndices = Set<int>();
  late Future<Map<String, dynamic>> hostelDataFuture;
  List<dynamic> filteredMainDisplayList = [];

  @override
  void initState() {
    super.initState();
    hostelDataFuture = fetchHostelData();
  }

  Future<Map<String, dynamic>> fetchHostelData() async {
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
        "StudentId": "1679",
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

  Future<void> saveStudentRegistration(List<Map<String, dynamic>> selectedRooms) async {
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "StudentId": "1679",
      "HostelId": selectedRooms[0]['hostelId'].toString(),
      "UserTypeName": "STUDENT",
      "AcYear": "2023 - 2024",
      "StartDate": "",
      "RegistrationDate": "2024-07-12",
      "RoomTypeId": selectedRooms[0]['roomTypeId'].toString(),
      "RoomId": selectedRooms[0]['roomId'].toString(),
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": "1",
      "HostelSaveRegularStudentRegistrationWithFeestablevariable": selectedRooms.map((room) => {
        "FeeId": room['feeId'],
        "Frequency": room['frequency'],
        "Installement": room['installement']
      }).toList()
    };

    print("Request Body: ${jsonEncode(requestBody)}"); // Print the request body for debugging

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/HostelSaveRegularStudentRegistrationWithFees'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print(response.body); // Print response for debugging

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Unknown error occurred'),
          backgroundColor: Colors.black, // You can customize this color based on the message or status
        ),
      );
    } else {
      print("Error: ${response.body}"); // Print error response for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseBody['message'] ?? 'Failed to save registration'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    if (selectedRoomIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one room to register')),
      );
      return;
    }

    final selectedRooms = selectedRoomIndices.map((index) {
      final room = filteredMainDisplayList[index];
      return {
        "hostelId": room['hostelId'],
        "roomTypeId": room['roomTypeId'],
        "roomId": room['roomId'],
        "feeId": room['feeId'],
        "frequency": room['frequency'],
        "installement": room['installement']
      };
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Registration'),
          content: Text('Are you sure you want to register for the selected rooms?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                saveStudentRegistration(selectedRooms); // Call the API
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          final mainDisplayList = data['mainDisplayList'] as List;

          // Debug prints to check data
          print("Hostels: $hostels");
          print("Room Types: $roomTypes");
          print("Vacancy Rooms: $vacancyRooms");
          print("Main Display List: $mainDisplayList");

          final filteredRoomTypes = selectedHostelId != null
              ? roomTypes.where((rt) => rt['hostelId'] == selectedHostelId).toList()
              : [];
          final filteredRooms = selectedRoomTypeId != null
              ? vacancyRooms.where((r) =>
          r['hostelId'] == selectedHostelId &&
              r['roomTypeId'] == selectedRoomTypeId).toList()
              : [];

          filteredMainDisplayList = selectedRoomId != null
              ? mainDisplayList.where((item) =>
          item['hostelId'] == selectedHostelId &&
              item['roomTypeId'] == selectedRoomTypeId &&
              item['roomId'] == selectedRoomId).toList()
              : [];

          // Debug prints to check filtered data
          print("Filtered Room Types: $filteredRoomTypes");
          print("Filtered Rooms: $filteredRooms");
          print("Filtered Main Display List: $filteredMainDisplayList");

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
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
                        });
                      },
                      items: filteredRoomTypes.map<DropdownMenuItem<int>>((roomType) {
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
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMainDisplayList.length,
                    itemBuilder: (context, index) {
                      final room = filteredMainDisplayList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedRoomIndices.contains(index) ? Colors.blue : Colors.transparent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Card(
                          elevation: 2.0,
                          margin: EdgeInsets.all(0.0),
                          child: ListTile(
                            tileColor: selectedRoomIndices.contains(index)
                                ? Colors.blue[50]
                                : Colors.white,
                            onTap: () {
                              setState(() {
                                if (selectedRoomIndices.contains(index)) {
                                  selectedRoomIndices.remove(index);
                                } else {
                                  selectedRoomIndices.add(index);
                                }
                              });
                            },
                            title: Text('Room Type: ${room['roomTypeName'] ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fee Name: ${room['feeName']}'),
                                Text('Total Fee Amount: ${room['totalFeeAmount']}'),
                                Text('Room Capacity: ${room['roomCapacity']}'),
                                Text('Allotted Beds: ${room['allottedBeds']}'),
                                Text('Available Beds: ${room['availableBeds']}'),
                                Text('Installements: ${room['installement']}'),
                              ],
                            ),
                            trailing: selectedRoomIndices.contains(index)
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
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

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selectedRoomId != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 200,
                child: FloatingActionButton(
                  onPressed: () {
                    if (selectedRoomIndices.isNotEmpty && filteredMainDisplayList.isNotEmpty) {
                      _showConfirmationDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select at least one room to register')),
                      );
                    }
                  },
                  child: Text("REGISTER", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

}
