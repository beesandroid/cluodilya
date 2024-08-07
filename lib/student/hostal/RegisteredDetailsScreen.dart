import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisteredDetailsScreen extends StatefulWidget {
  @override
  _RegisteredDetailsScreenState createState() => _RegisteredDetailsScreenState();
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
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayForStudentSearch'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "bees",
        "ColCode": "0001",
        "StudentId": "2548",
        "Flag": "HostelStatus"
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
      throw Exception('Failed to load data');
    }
  }

  void showHistoryDialog() {
    if (apiResponse == null) return;
    final viewHistoryList = apiResponse!['viewHistoryList'] as List<dynamic>;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('History'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: viewHistoryList.map((history) {
                return ListTile(
                  title: Text('${history['hostelName']}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
            CupertinoDialogAction(
              child: Text('Close',style: TextStyle(color: Colors.black),),
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
    return CupertinoPageScaffold(


      child: SafeArea(
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : apiResponse == null
            ? Center(child: Text('Failed to load data'))
            : AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.history_toggle_off_outlined),
                    onPressed: showHistoryDialog,
                  ),
                ],
              ),
              if (apiResponse!['stuedntDisplaySearchList'] != null)
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
                            ' ${item['hostelName']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Room Type: ${item['roomTypeName']}'),
                          Text('Room Number: ${item['roomNumber']}'),
                          Text('Block Name: ${item['blockName']}'),
                          Text('Floor Name: ${item['floorName']}'),
                          Text('Total Paid Amount: ${item['totalCollectedAmount']}'),
                          Text('Due Amount: ${item['dueAmount']}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              SizedBox(height: 16),
              if (apiResponse!['installmentsDisplayList'] != null)
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Amount: ${item['amount']}'),
                          Text('Due Amount: ${item['dueAmount']}'),
                          Text('Collected Amount: ${item['collectedAmount']}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
