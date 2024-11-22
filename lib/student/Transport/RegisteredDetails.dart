import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TransportRegistrationDetailsScreen extends StatefulWidget {
  @override
  _TransportRegistrationDetailsScreenState createState() =>
      _TransportRegistrationDetailsScreenState();
}

class _TransportRegistrationDetailsScreenState
    extends State<TransportRegistrationDetailsScreen> {
  Map<String, dynamic>? apiResponse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayForStudentSearch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": grpCode,
          "ColCode": colCode,
          "StudentId": studId,
          "Flag": "TransportStatus"
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);

        setState(() {
          apiResponse = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Optionally, show a SnackBar or other UI element to indicate failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching data')),
      );
    }
  }

  void showHistoryDialog() {
    if (apiResponse == null) return;
    final viewHistoryList = apiResponse!['transportViewList'] as List<dynamic>?;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(child: Text('Transport History')),
          content: viewHistoryList == null || viewHistoryList.isEmpty
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'No history available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          )
              : SingleChildScrollView(
            child: Column(
              children: viewHistoryList.map((history) {
                return ListTile(
                  title: Text(
                    '${history['busNumber']} - ${history['routeName']}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stage Name: ${history['stageName']}'),
                      Text('Bus Type: ${history['busTypeName']}'),
                      Text('Amount: ${history['amount']}'),
                      Text('Due Amount: ${history['dueAmount']}'),
                      Text('Collected Amount: ${history['collectedAmount']}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Close', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
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


      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.history_toggle_off_outlined),
                onPressed: showHistoryDialog,
              ),
            ],
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : apiResponse == null
                ? const Center(
              child: Text(
                'Failed to load data',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: apiResponse!['transportDetailsList'] == null ||
                  apiResponse!['transportDetailsList'].isEmpty &&
                      apiResponse!['transportFeeDetailsList'] == null ||
                  apiResponse!['transportFeeDetailsList'].isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No data available.',
                      style: TextStyle(
                          fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView(
                children: [
                  if (apiResponse!['transportDetailsList'] != null &&
                      apiResponse!['transportDetailsList'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transport Details',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        ...apiResponse!['transportDetailsList']
                            .map<Widget>((item) {
                          return Container(
                            margin:
                            const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['busNumber']} - ${item['routeName']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Stage Name: ${item['stageName']}'),
                                  Text('Sub Route: ${item['subRoute']}'),
                                  Text('Amount: ${item['amount']}'),
                                  Text(
                                      'Registration Date: ${item['registrationDate']}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (apiResponse!['transportFeeDetailsList'] != null &&
                      apiResponse!['transportFeeDetailsList'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transport Fee Details',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        ...apiResponse!['transportFeeDetailsList']
                            .map<Widget>((item) {
                          return Container(
                            margin:
                            const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fee Name: ${item['feeName']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Amount: ${item['amount']}'),
                                  Text(
                                      'Due Amount: ${item['dueAmount']}'),
                                  Text(
                                      'Collected Amount: ${item['collectedAmount']}'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  // If both lists are present but one is empty, show a message
                  if ((apiResponse!['transportDetailsList'] == null ||
                      apiResponse!['transportDetailsList']
                          .isEmpty) &&
                      apiResponse!['transportFeeDetailsList'] != null &&
                      apiResponse!['transportFeeDetailsList']
                          .isNotEmpty)
                    const SizedBox(height: 20),
                  if ((apiResponse!['transportDetailsList'] == null ||
                      apiResponse!['transportDetailsList']
                          .isEmpty) &&
                      apiResponse!['transportFeeDetailsList'] != null &&
                      apiResponse!['transportFeeDetailsList']
                          .isNotEmpty)
                    const Center(
                      child: Text(
                        'No Transport Details Available.',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  if (apiResponse!['transportDetailsList'] != null &&
                      apiResponse!['transportDetailsList'].isNotEmpty &&
                      (apiResponse!['transportFeeDetailsList'] == null ||
                          apiResponse!['transportFeeDetailsList']
                              .isEmpty))
                    const Center(
                      child: Text(
                        'No Transport Fee Details Available.',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
