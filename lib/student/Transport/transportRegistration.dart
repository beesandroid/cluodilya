import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransportRegistrationScreen extends StatefulWidget {
  const TransportRegistrationScreen({super.key});

  @override
  State<TransportRegistrationScreen> createState() =>
      _TransportRegistrationScreenState();
}

class _TransportRegistrationScreenState
    extends State<TransportRegistrationScreen> {
  String? selectedSeatNumber;
  Map<String, dynamic>? selectedBusData; // Update to nullable String

  List<Map<String, dynamic>> stageSearchList = [];
  String? selectedRoute;
  String selectedSeat = "No seat selected";
  List<String> routeNames = [];
  List<Map<String, dynamic>> busTypes = [];
  String? selectedBusType;
  List<Map<String, dynamic>> busNumberList = [];
  String? selectedBusNumber;
  List<Map<String, dynamic>> busLayout = []; // New variable for bus layout

  @override
  void initState() {
    super.initState();
    _fetchStageSearchData();
  }

  Future<void> _fetchStageSearchData() async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StageSearchDisplay';
    const requestBody = {
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "64",
      "Str": "",
      "RouteId": 0,
      "StageId": 0,
      "BusTypeId": 0,
      "BusId": 0,
      "LayoutId": 0,
      "Saved": 1
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedStageList = data['stageSearchList'];

        setState(() {
          stageSearchList = fetchedStageList.cast<Map<String, dynamic>>();
          routeNames =
              stageSearchList.map((item) => item['stage'] as String).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _fetchBusTypeData(int routeId, int stageId) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BusTypeDropDown';

    final requestBody = {
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "64",
      "Str": "",
      "RouteId": routeId,
      "StageId": stageId,
      "BusTypeId": 0,
      "BusId": "0",
      "LayoutId": 0,
      "Saved": 1
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> busTypesList = data['busTypesList'];

        setState(() {
          busTypes = busTypesList.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load bus type data');
      }
    } catch (error) {
      print('Error fetching bus type data: $error');
    }
  }

  Future<void> _fetchBusNumbers(int routeId, int stageId, int busTypeId) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BusNumberDropDown';

    final requestBody = {
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "64",
      "Str": "",
      "RouteId": routeId,
      "StageId": stageId,
      "BusTypeId": busTypeId,
      "BusId": 0,
      "LayoutId": 0,
      "Saved": "1"
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> busNoList = data['busNoList'];

        setState(() {
          busNumberList = busNoList.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load bus numbers');
      }
    } catch (error) {
      print('Error fetching bus numbers: $error');
    }
  }

  Future<void> _fetchBusLayout(
      int busId, int routeId, int stageId, int busTypeId, int layoutId) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayTransportRegistration';

    final requestBody = {
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "64",
      "Str": "",
      "RouteId": routeId,
      "StageId": stageId,
      "BusTypeId": busTypeId,
      "BusId": busId,
      "LayoutId": layoutId,
      "Saved": 1
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['layOutDisplayList'] != null) {
          final List<dynamic> rows = data['layOutDisplayList']['rows'];
          setState(() {
            busLayout =
                rows.map((item) => item as Map<String, dynamic>).toList();
          });

// Fetch bus layout when a bus number is selected
        } else {
          print('No bus layout data available');
          setState(() {
            busLayout = [];
          });
        }
      } else {
        throw Exception('Failed to load bus layout');
      }
    } catch (error) {
      print('Error fetching bus layout: $error');
    }
  }

  Future<void> _fetchTransportFees(int busId, String seatNumber, int routeId,
      int stageId, int busTypeId, int layoutId) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeesDisplayForTransport';

    // Modify your request body as per your application logic
    final requestBody = {
      "GrpCode": "BEESDEV",
      "ColCode": "0001",
      "Acyear": "2024 - 2025",
      "UserTypeName": "STUDENT",
      "StudentId": "64",
      "Str": "",
      "RouteId": routeId, // Use selected route id
      "StageId": stageId, // Use selected stage id
      "BusTypeId": busTypeId, // Use selected bus type id
      "BusId": busId, // Use selected bus id
      "LayoutId": layoutId, // Use selected layout id
      "Saved": 1
    };
    print(requestBody);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final feesList = data['displayFeesList'];

        if (feesList != null && feesList.isNotEmpty) {
          setState(() {
            // Show ticket info on UI based on the response
            _showTicketDialog(feesList[0]);
          });
        } else {
          print('No fee data available');
        }
      } else {
        throw Exception('Failed to fetch transport fees');
      }
    } catch (error) {
      print('Error fetching transport fees: $error');
    }
  }

  void _showTicketDialog(Map<String, dynamic> ticketData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.blueAccent, // You can change this to your preferred color
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.directions_bus, // Ticket icon
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Transport Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTicketInfoRow('Route', ticketData['routeName']),
              _buildTicketInfoRow('Bus Type', ticketData['busType']),
              _buildTicketInfoRow('Stage', ticketData['stageName']),
              _buildTicketInfoRow('Total Fee', '₹${ticketData['totalFeeAmount']}'),
              _buildTicketInfoRow('Frequency', ticketData['frequency']),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 10), // Space between buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Save'),
                  onPressed: () {
                    _saveTransportTicket(ticketData);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],

        );
      },
    );
  }

  Widget _buildTicketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _saveTransportTicket(Map<String, dynamic> ticketData) async {
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentTransportRegistration';

    final requestBody = {
      "GrpCode": "bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "UserId": "1",
      "StudentId": "1642",
      "StartDate": "2024-07-29",
      "UserType": "1",
      "AcYear": "2024 - 2025",
      "RouteId": ticketData['routeId'],
      "StageId": ticketData['stageId'],
      "RegistrationDate": "2024-09-24",
      "BusTypeId": ticketData['busTypeId'],
      "BusId": ticketData['busId'],
      "SeatNumber": selectedSeatNumber,
      "Description": "Description here",
      "Saved": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "TransportStudentRegistrationTablevariable": [
        {
          "FeeId": ticketData['feeId'],
          "Frequency": ticketData['frequency'],
          "Installement": ticketData['installmentStatus']
        }
      ]
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Handle success response
        final responseData = jsonDecode(response.body);
        String message = responseData['displayMessage'] ?? 'Success!';
        _showSnackbar(context, message);

        print(responseData);

        print('Transport ticket saved successfully: $responseData');
      } else {
        throw Exception('Failed to save transport ticket');
      }
    } catch (error) {
      print('Error saving transport ticket: $error');
    }
  }
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Adjust duration as needed
      ),
    );
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
          'Transport Registration',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Route:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedRoute,
              hint: const Text('Select a route'),
              items: routeNames.map((routeName) {
                return DropdownMenuItem<String>(
                  value: routeName,
                  child: Text(routeName),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedRoute = newValue;
                });
                try {
                  final selectedRouteData = stageSearchList.firstWhere(
                    (item) => item['stage'] == selectedRoute,
                    orElse: () => throw Exception('No matching route found'),
                  );
                  final int routeId = selectedRouteData['routeId'];
                  final int stageId = selectedRouteData['stageId'];
                  _fetchBusTypeData(routeId, stageId);
                } catch (e) {
                  print(e);
                }
              },
            ),
            const SizedBox(height: 20),
            if (busTypes.isNotEmpty) ...[
              const Text(
                'Select Bus Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: selectedBusType,
                hint: const Text('Select a bus type'),
                items: busTypes.map((busType) {
                  return DropdownMenuItem<String>(
                    value: busType['busType'],
                    child: Text(busType['busType']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedBusType = newValue;
                  });

                  final selectedBusTypeData = busTypes.firstWhere(
                    (type) => type['busType'] == selectedBusType,
                    orElse: () => {'busTypeId': 0},
                  );

                  final int routeId = stageSearchList.firstWhere(
                        (item) => item['stage'] == selectedRoute,
                        orElse: () => {'routeId': 0},
                      )['routeId'] ??
                      0;

                  final int stageId = stageSearchList.firstWhere(
                        (item) => item['stage'] == selectedRoute,
                        orElse: () => {'stageId': 0},
                      )['stageId'] ??
                      0;
                  final int busTypeId = selectedBusTypeData['busTypeId'];
                  _fetchBusNumbers(routeId, stageId, busTypeId);
                },
              ),
            ],
            const SizedBox(height: 20),
            if (busNumberList.isNotEmpty) ...[
              const Text(
                'Select Bus Number:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: selectedBusNumber,
                hint: const Text('Select a bus number'),
                items: busNumberList.map((bus) {
                  return DropdownMenuItem<String>(
                    value: bus['busNumber'],
                    child: Text(bus['busNumber']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedBusNumber = newValue;
                    selectedBusData = busNumberList.firstWhere(
                      (bus) => bus['busNumber'] == newValue,
                      orElse: () => {'busId': 0},
                    ); // Ensure selectedBusData is updated with the correct bus information
                  });

                  // Fetch the bus layout
                  final int busId = selectedBusData!['busId'];
                  final int routeId = selectedBusData!['routeId'];
                  final int stageId = selectedBusData!['stageId'];
                  final int busTypeId = selectedBusData!['busTypeId'];
                  final int layoutId = selectedBusData!['layOutId'];
                  _fetchBusLayout(busId, routeId, stageId, busTypeId, layoutId);
                },
              ),
            ],
            if (busLayout.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Select a Seat:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: busLayout.length,
                  itemBuilder: (context, rowIndex) {
                    final row = busLayout[rowIndex];
                    final seats = row['seats'] as List<dynamic>;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: seats.map<Widget>((seat) {
                        final bool isAvailable = seat['isAvailable'] as bool;
                        final String seatNumber = seat['seatNumber'] as String;

                        Icon seatIcon;
                        if (isAvailable) {
                          seatIcon = selectedSeatNumber == seatNumber
                              ? Icon(Icons.chair, color: Colors.blue, size: 30) // Selected seat
                              : Icon(Icons.chair_alt, color: Colors.green, size: 30); // Available seat
                        } else {
                          seatIcon = Icon(Icons.chair, color: Colors.red, size: 30); // Unavailable seat
                        }

                        return GestureDetector(
                          onTap: isAvailable
                              ? () {
                            setState(() {
                              selectedSeatNumber = seatNumber;
                            });
                          }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.all(4.0),
                            width: 40,
                            height: 40,
                            child: Center(child: seatIcon),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
              ,
              const SizedBox(height: 20),
              if (selectedSeatNumber != null)
                Text(
                  'Selected Seat: $selectedSeatNumber',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: (selectedSeatNumber != null &&
                        selectedBusData != null &&
                        selectedBusData!['busId'] != 0)
                    ? () {
                        final int busId = selectedBusData!['busId'];
                        final int routeId = selectedBusData!['routeId'];
                        final int stageId = selectedBusData!['stageId'];
                        final int busTypeId = selectedBusData!['busTypeId'];
                        final int layoutId = selectedBusData!['layOutId'];
                        _fetchTransportFees(busId, selectedSeatNumber!, routeId,
                            stageId, busTypeId, layoutId);
                      }
                    : null, // Disable button if conditions are not met
                child: const Text(
                  'Confirm Seat Selection',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
