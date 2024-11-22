import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransportRegistrationScreen extends StatefulWidget {
  const TransportRegistrationScreen({super.key});

  @override
  State<TransportRegistrationScreen> createState() =>
      _TransportRegistrationScreenState();
}

class _TransportRegistrationScreenState
    extends State<TransportRegistrationScreen> {
  String? selectedSeatNumber;
  Map<String, dynamic>? selectedBusData;

  List<Map<String, dynamic>> stageSearchList = [];
  Map<String, dynamic>? selectedRouteData; // Updated to store selected route data
  String selectedSeat = "No seat selected";
  List<Map<String, dynamic>> busTypes = [];
  String? selectedBusType;
  List<Map<String, dynamic>> busNumberList = [];
  String? selectedBusNumber;
  List<Map<String, dynamic>> busLayout = [];

  @override
  void initState() {
    super.initState();
    _fetchStageSearchData();
  }

  Future<void> _fetchStageSearchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';

    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StageSearchDisplay';
    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "Acyear": acYear,
      "UserTypeName": "STUDENT",
      "StudentId": studId,
      "Str": "",
      "RouteId": 0,
      "StageId": 0,
      "BusTypeId": 0,
      "BusId": 0,
      "LayoutId": 0,
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
        final List<dynamic> fetchedStageList = data['stageSearchList'];

        setState(() {
          stageSearchList = fetchedStageList.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _fetchBusTypeData(int routeId, int stageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BusTypeDropDown';

    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "Acyear": acYear,
      "UserTypeName": "STUDENT",
      "StudentId": studId,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';

    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BusNumberDropDown';

    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "Acyear": acYear,
      "UserTypeName": "STUDENT",
      "StudentId": studId,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayTransportRegistration';

    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "Acyear": acYear,
      "UserTypeName": "STUDENT",
      "StudentId": studId,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeesDisplayForTransport';
    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "Acyear": acYear,
      "UserTypeName": "STUDENT",
      "StudentId": studId,
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

        final feesList = data['displayFeesList'];

        if (feesList != null && feesList.isNotEmpty) {
          setState(() {
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
              color: Colors.blueAccent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.directions_bus,
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
              _buildTicketInfoRow(
                  'Total Fee', '₹${ticketData['totalFeeAmount']}'),
              _buildTicketInfoRow('Frequency', ticketData['frequency']),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
    final DateTime today = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(today);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';

    const apiUrl =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveStudentTransportRegistration';

    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": "1",
      "UserId": adminUserId,
      "StudentId": studId,
      "StartDate": "2024-07-29",
      "UserType": "8",
      "AcYear": acYear,
      "RouteId": ticketData['routeId'],
      "StageId": ticketData['stageId'],
      "RegistrationDate": formattedDate,
      "BusTypeId": selectedBusData!['busTypeId'],
      "BusId": selectedBusData!['busId'],
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
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Stage - Route:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedRouteData,
              isExpanded: true,
              hint: const Text('Select a stage and route'),
              items: stageSearchList.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(
                    '${item['stage']} - ${item['routeName']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedRouteData = newValue;
                  selectedBusType = null;
                  busTypes = [];
                  selectedBusNumber = null;
                  busNumberList = [];
                  busLayout = [];
                  selectedSeatNumber = null;
                });
                if (selectedRouteData != null) {
                  final int routeId = selectedRouteData!['routeId'];
                  final int stageId = selectedRouteData!['stageId'];
                  _fetchBusTypeData(routeId, stageId);
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
                    selectedBusNumber = null;
                    busNumberList = [];
                    busLayout = [];
                    selectedSeatNumber = null;
                  });

                  final selectedBusTypeData = busTypes.firstWhere(
                        (type) => type['busType'] == selectedBusType,
                    orElse: () => {'busTypeId': 0},
                  );

                  final int routeId = selectedRouteData!['routeId'];
                  final int stageId = selectedRouteData!['stageId'];
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
                    );
                    busLayout = [];
                    selectedSeatNumber = null;
                  });

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
                child: SingleChildScrollView(
                  child: Center(
                    child: BusLayoutWidget(
                      busLayout: busLayout,
                      selectedSeatNumber: selectedSeatNumber,
                      onSeatSelected: (seatNumber) {
                        setState(() {
                          selectedSeatNumber = seatNumber;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (selectedSeatNumber != null)
                Text(
                  'Selected Seat: $selectedSeatNumber',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
                    : null,
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

// Custom widget for the bus layout
class BusLayoutWidget extends StatelessWidget {
  final List<Map<String, dynamic>> busLayout;
  final String? selectedSeatNumber;
  final Function(String) onSeatSelected;

  BusLayoutWidget({
    required this.busLayout,
    required this.selectedSeatNumber,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          // Driver's seat representation
          Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.brown[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Driver',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Seats layout
          Column(
            children: busLayout.map((row) {
              final seats = row['seats'] as List<dynamic>;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: seats.map<Widget>((seat) {
                  final bool isAvailable = seat['isAvailable'] as bool;
                  final String seatNumber = seat['seatNumber'] as String;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () {
                      onSeatSelected(seatNumber);
                    }
                        : null,
                    child: SeatWidget(
                      seatNumber: seatNumber,
                      isAvailable: isAvailable,
                      isSelected: selectedSeatNumber == seatNumber,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Custom widget for each seat
class SeatWidget extends StatelessWidget {
  final String seatNumber;
  final bool isAvailable;
  final bool isSelected;

  SeatWidget({
    required this.seatNumber,
    required this.isAvailable,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    IconData seatIcon = Icons.event_seat;
    Color iconColor;

    if (!isAvailable) {
      iconColor = Colors.red;
    } else if (isSelected) {
      iconColor = Colors.green;
    } else {
      iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      width: 40,
      height: 40,
      child: Icon(
        seatIcon,
        color: iconColor,
        size: 45,
      ),
    );
  }
}