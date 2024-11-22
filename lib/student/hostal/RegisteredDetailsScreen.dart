import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisteredDetailsScreen extends StatefulWidget {
  @override
  _RegisteredDetailsScreenState createState() =>
      _RegisteredDetailsScreenState();
}

class _RegisteredDetailsScreenState extends State<RegisteredDetailsScreen> {
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

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayForStudentSearch'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": grpCode,
        "ColCode": colCode,
        "StudentId": studId,
        "Flag": "HostelStatus"
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        apiResponse = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  void showHistoryDialog() {
    if (apiResponse == null || apiResponse!['viewHistoryList'] == null) return;

    final viewHistoryList = apiResponse!['viewHistoryList'] as List<dynamic>;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('History', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              children: viewHistoryList.map((history) {
                return ListTile(
                  title: Text(
                    '${history['hostelName']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Room Type: ${history['roomTypeName']}'),
                      Text('Block Name: ${history['blockName']}'),
                      Text('Floor Name: ${history['floorName']}'),
                      Text('Amount: ${history['amount']}'),
                      Text('Due Amount: ${history['dueAmount']}'),
                      Text('Paid Amount: ${history['collectedAmount']}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : apiResponse == null
            ? Center(
          child: Text(
            'Failed to load data',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            if (apiResponse!['stuedntDisplaySearchList'] != null &&
                apiResponse!['stuedntDisplaySearchList'].isNotEmpty)
              ...apiResponse!['stuedntDisplaySearchList']
                  .map<Widget>((item) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['hostelName']}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Room Type: ${item['roomTypeName']}'),
                        Text('Room Number: ${item['roomNumber']}'),
                        Text('Block Name: ${item['blockName']}'),
                        Text('Floor Name: ${item['floorName']}'),
                        Text(
                            'Total Paid Amount: ${item['totalCollectedAmount']}'),
                        Text('Due Amount: ${item['dueAmount']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            if (apiResponse!['installmentsDisplayList'] != null &&
                apiResponse!['installmentsDisplayList'].isNotEmpty)
              ...apiResponse!['installmentsDisplayList']
                  .map<Widget>((item) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fee Name: ${item['feeName']}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Amount: ${item['amount']}'),
                        Text('Due Amount: ${item['dueAmount']}'),
                        Text(
                            'Collected Amount: ${item['collectedAmount']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            if ((apiResponse!['stuedntDisplaySearchList'] == null ||
                apiResponse!['stuedntDisplaySearchList']
                    .isEmpty) &&
                (apiResponse!['installmentsDisplayList'] == null ||
                    apiResponse!['installmentsDisplayList']
                        .isEmpty))
              Center(
                child: Text(
                  'No Data Available',
                  style:
                  TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
