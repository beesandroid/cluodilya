import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransportRegistrationScreen extends StatefulWidget {
  @override
  _TransportRegistrationScreenState createState() =>
      _TransportRegistrationScreenState();
}

class _TransportRegistrationScreenState
    extends State<TransportRegistrationScreen> {
  List<dynamic> stageSearchList = [];
  List<dynamic> busTypesList = [];
  List<dynamic> busNoWithTimingsList = [];
  List<dynamic> layOutDisplayList = [];
  List<dynamic> displayFeesList = [];
  List<dynamic> seatsList = [];
  dynamic selectedStage;
  dynamic selectedBusType;
  dynamic selectedBusTiming;
  String? selectedSeat;
  int? selectedFeeIndex;
  List<dynamic> transportMainDisplayList = [];

  @override
  void initState() {
    super.initState();
    _fetchTransportRegistrationData();
  }

  Color _getSeatColor(String? genderName, bool isSelected) {
    if (isSelected) {
      return Colors.green; // Color for selected seat
    } else if (genderName == 'Male') {
      return Colors.blue; // Color for male seats
    } else if (genderName == 'Female') {
      return Colors.pink; // Color for female seats
    } else {
      return Colors.grey; // Color for empty seats
    }
  }

  Future<void> _fetchTransportRegistrationData() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayTransportRegistration';
    const requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "1689",
      "Str": "",
      "RouteId": "0",
      "StageId": "0",
      "BusTypeId": "0",
      "BusId": "0",
      "LayoutId": "0",
      "Saved": "1"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stageSearchList = data['stageSearchList'] ?? [];
          busTypesList = data['busTypesList'] ?? [];
          busNoWithTimingsList = data['busNoWithTimingsList'] ?? [];
          layOutDisplayList = data['layOutDisplayList'] ?? [];
          displayFeesList = data['displayFeesList'] ?? [];
          seatsList = _flattenSeatLayout(layOutDisplayList)
              .map((seat) => seat['seatNo'].toString())
              .toList();
        });
      } else {
        _showErrorSnackbar('Failed to load data. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Network error. Please check your connection.');
    }
  }

  Future<void> _registerSeat() async {
    if (selectedSeat == null ||
        selectedBusTiming == null ||
        selectedStage == null ||
        selectedBusType == null ||
        selectedFeeIndex == null) return;

    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentTransportRegistration';
    final requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "UserId": "1",
      "StudentId": "1689",
      "StartDate": "2024-07-29", // Adjust as necessary
      "UserType": "8",
      "AcYear": "2024 - 2025",
      "RouteId": selectedStage['routeId'].toString(),
      "StageId": selectedStage['stageId'].toString(),
      "RegistrationDate": "2024-07-30", // Adjust as necessary
      "BusTypeId": selectedBusType['busTypeId'].toString(),
      "BusId": selectedBusTiming['busId'].toString(),
      "SeatNumber": selectedSeat,
      "Description": "rtryh", // Adjust as necessary
      "Saved": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "TransportStudentRegistrationTablevariable": [
        {
          "FeeId": displayFeesList.isNotEmpty
              ? displayFeesList[selectedFeeIndex!]['feeId']
              : "0",
          "Frequency": displayFeesList.isNotEmpty
              ? displayFeesList[selectedFeeIndex!]['frequency']
              : "0",
          "Installement": displayFeesList.isNotEmpty
              ? displayFeesList[selectedFeeIndex!]['installmentStatus']
              : "no",
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        final displayMessage =
            data['displayMessage'] ?? 'Registration successful.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(displayMessage)));
        // Optionally clear the selection or refresh the UI
      } else {
        _showErrorSnackbar('Failed to register. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Network error. Please check your connection.');
    }
  }

  List<Map<String, dynamic>> _flattenSeatLayout(List<dynamic> layoutList) {
    List<Map<String, dynamic>> seats = [];
    for (var layout in layoutList) {
      for (int i = 1; i <= 5; i++) {
        int? seatNumber = layout['column$i'];
        if (seatNumber != null) {
          seats.add({
            'seatNo': seatNumber,
            'busTypeId': layout['busTypeId'],
            'busTypeName': layout['busTypeName'],
          });
        }
      }
    }
    return seats;
  }

  Future<void> _fetchUpdatedTransportData() async {
    if (selectedStage == null ||
        selectedBusType == null ||
        selectedBusTiming == null) return;

    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayTransportRegistration';
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "1689",
      "Str": "",
      "RouteId": selectedStage['routeId'].toString(),
      "StageId": selectedStage['stageId'].toString(),
      "BusTypeId": selectedBusType['busTypeId'].toString(),
      "BusId": selectedBusTiming['busId'].toString(),
      "LayoutId": selectedBusTiming['layOutId'].toString(),
      "Saved": "1"
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          layOutDisplayList = data['layOutDisplayList'] ?? [];
          transportMainDisplayList = data['transportMainDisplayList'] ?? [];
          seatsList = _flattenSeatLayout(layOutDisplayList)
              .map((seat) => seat['seatNo'].toString())
              .toList();
          displayFeesList = data['displayFeesList'] ?? [];
        });
      } else {
        _showErrorSnackbar('Failed to load data. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Network error. Please check your connection.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<dynamic> _filterBusTypes() {
    if (selectedStage == null) return [];

    int selectedStageId = selectedStage['stageId'];
    return busTypesList.where((busType) {
      return busType['stageId'] == selectedStageId;
    }).toList();
  }

  List<dynamic> _filterBusTimings() {
    if (selectedBusType == null || selectedStage == null) return [];

    int selectedBusTypeId = selectedBusType['busTypeId'];
    return busNoWithTimingsList.where((timing) {
      return timing['busTypeId'] == selectedBusTypeId &&
          timing['stageId'] == selectedStage['stageId'];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBusTypes = _filterBusTypes();
    final filteredBusTimings = _filterBusTimings();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Select Stage',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              value: selectedStage,
              items: stageSearchList.map((stage) {
                return DropdownMenuItem<dynamic>(
                  value: stage,
                  child: Text(stage['stage'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (dynamic newValue) {
                setState(() {
                  selectedStage = newValue;
                  selectedBusType = null;
                  selectedBusTiming = null;
                  selectedSeat = null;
                  selectedFeeIndex = null;
                  _fetchUpdatedTransportData();
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Select Bus Type',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              value: selectedBusType,
              items: filteredBusTypes.map((busType) {
                return DropdownMenuItem<dynamic>(
                  value: busType,
                  child: Text(busType['busType'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (dynamic newValue) {
                setState(() {
                  selectedBusType = newValue;
                  selectedBusTiming = null;
                  selectedSeat = null;
                  selectedFeeIndex = null;
                  _fetchUpdatedTransportData();
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<dynamic>(
              decoration: InputDecoration(
                labelText: 'Select Bus Timing',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              value: selectedBusTiming,
              items: filteredBusTimings.map((timing) {
                return DropdownMenuItem<dynamic>(
                  value: timing,
                  child: Text(
                    'Bus ${timing['busNumber'] ?? 'Unknown'} (${timing['morningTime']} - ${timing['eveningTime']})',
                  ),
                );
              }).toList(),
              onChanged: (dynamic newValue) {
                setState(() {
                  selectedBusTiming = newValue;
                  selectedSeat = null;
                  selectedFeeIndex = null;
                  _fetchUpdatedTransportData();
                });
              },
            ),
            SizedBox(height: 16),
            if (selectedStage != null &&
                selectedBusType != null &&
                selectedBusTiming != null &&
                selectedBusTiming['layOutId'] == 0)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Seat',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                value: selectedSeat,
                items: seatsList.map((seat) {
                  return DropdownMenuItem<String>(
                    value: seat,
                    child: Text(seat),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSeat = newValue;
                  });
                },
              ),
            SizedBox(height: 16),
            if (selectedStage != null &&
                selectedBusType != null &&
                selectedBusTiming != null &&
                selectedBusTiming['layOutId'] != 0)
              Expanded(
                child: Container(
                  width: 300,
                  height: 200, // Ensure fixed height to avoid layout issues
                  padding: EdgeInsets.all(8), // Padding around GridView
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Adjust columns as needed
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: seatsList.length,
                    itemBuilder: (context, index) {
                      final seat = seatsList[index];
                      final seatData = layOutDisplayList.firstWhere(
                        (layout) => layout['seatNo'] == seat,
                        orElse: () => {},
                      );

                      // Get seat gender name from seatData
                      final genderName =
                          seatData['genderName'] ?? ''; // Added null check
                      final isSelected = selectedSeat == seat;

                      return GestureDetector(
                        onTap: () {
                          // No need for the if statement here!
                          setState(() {
                            selectedSeat = seat;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getSeatColor(genderName, isSelected),
                            // Use _getSeatColor
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chair, // Use the chair icon
                                color: Colors.white,
                                size: 24, // Adjust size as needed
                              ),
                              Text(
                                seat,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (selectedSeat != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Selected Seat: $selectedSeat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            if (selectedStage != null &&
                selectedBusType != null &&
                selectedBusTiming != null)
              Expanded(
                child: ListView.builder(
                  itemCount: displayFeesList.length,
                  itemBuilder: (context, index) {
                    final fee = displayFeesList[index];
                    final isSelected = index == selectedFeeIndex;
                    return Padding(
                      padding: const EdgeInsets.only(top: 22.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text('Fee Name: ${fee['feeName']}'),
                          subtitle: Text(
                              'Amount: ${fee['totalFeeAmount']} \nInstallment Status: ${fee['installmentStatus']} \nRoute Name: ${fee['routeName']}'),
                          tileColor: isSelected ? Colors.blue.shade50 : null,
                          onTap: () {
                            setState(() {
                              selectedFeeIndex = index;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (selectedSeat != null && selectedFeeIndex != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        _registerSeat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                      ),
                      child: Text('Register',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
