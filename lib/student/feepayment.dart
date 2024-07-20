import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeeDetailsScreen extends StatefulWidget {
  @override
  _FeeDetailsScreenState createState() => _FeeDetailsScreenState();
}

class _FeeDetailsScreenState extends State<FeeDetailsScreen> {
  List<dynamic> feeDetailsList = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectedFeeIds = {};

  @override
  void initState() {
    super.initState();
    fetchFeeDetails();
  }

  Future<void> fetchFeeDetails() async {
    final Uri url = Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SearchStudentRegularFeeDetails');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "HostelId": "0",
      "ReceiptNumber": "0",
      "HallTicketNo": "22H41AO485",
      "UserTypeName": "Student",
      "FeeSetUpId": "",
      "ReceiptDate": "",
      "Flag": "AR"
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        feeDetailsList = data['cloudilyaStudentRegularFeeDetailsList'] ?? [];
        _controllers.clear();  // Clear previous controllers
        _selectedFeeIds.clear(); // Clear previous selected fee IDs
        for (var feeDetail in feeDetailsList) {
          final feeId = feeDetail['feeId'].toString(); // Ensure feeId is a String
          _controllers[feeId] = TextEditingController();
        }
      });
    } else {
      // Handle error
      print('Failed to load fee details');
    }
  }

  void _payAmount(String feeId) {
    final amountToPay = _controllers[feeId]?.text;
    // Handle the payment logic here
    print('Paying amount: $amountToPay for fee ID: $feeId');
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(
        title: Text('Student Fee Details'),
        backgroundColor: Colors.white,
      ),
      body: feeDetailsList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: feeDetailsList.length,
        itemBuilder: (context, index) {
          final feeDetail = feeDetailsList[index];
          final feeId = feeDetail['feeId'].toString();

          return
            Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                title: Text(
                  feeDetail['feeName'] ?? 'Unknown Fee',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
                trailing: Icon(Icons.expand_more, color: Colors.black),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'Amount: ${feeDetail['amount']}',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Due: ${feeDetail['dueAmount']}',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.redAccent),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Period: ${feeDetail['period']}',
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Semester: ${feeDetail['semester']}',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Text(
                              'Fine: ${feeDetail['fine']}',
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          TextField(
                            controller: _controllers[feeId],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Amount to Pay',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                          ),
                          SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 220,
                                child: ElevatedButton(
                                  onPressed: () => _payAmount(feeId),
                                  child: Text('Pay'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )

                  ),
                ],
                onExpansionChanged: (bool expanded) {
                  if (expanded) {
                    setState(() {
                      _selectedFeeIds[feeId] = feeId;
                    });
                  } else {
                    setState(() {
                      _selectedFeeIds.remove(feeId);
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
