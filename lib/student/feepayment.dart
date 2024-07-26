import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  List<dynamic> feeDetails = [];
  Map<int, double> paymentAmounts = {};
  double totalDueAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchFeeDetails();
  }

  Future<void> fetchFeeDetails() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SearchStudentRegularFeeDetails'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
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
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        feeDetails =
            jsonDecode(response.body)['cloudilyaStudentRegularFeeDetailsList'];
      });
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  void updateTotalDueAmount() {
    setState(() {
      totalDueAmount =
          paymentAmounts.values.fold(0, (sum, amount) => sum + amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Fee Payment',
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: feeDetails.length,
                  itemBuilder: (context, index) {
                    final feeDetail = feeDetails[index];
                    final dueAmount = feeDetail['dueAmount'] ?? 0.0;
                    final feeName = feeDetail['feeName'] ?? 'Unknown Fee';
                    final period = feeDetail['period'] ?? 'N/A';
                    final amount = feeDetail['amount'] ?? 0.0;
                    final fineAmount = feeDetail['fineAmount'] ?? 0.0;
                    final collectedAmount = feeDetail['collectedAmount'] ?? 0.0;

                    if (dueAmount == 0) {
                      return SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Material(
                        color: Colors.white,
                        elevation: 15,
                        shadowColor: Colors.black38,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                feeName,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              Text('Period: $period',
                                  style: TextStyle(color: Colors.black)),
                              Text('Amount: ₹${amount.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.black)),
                              Text('Fine Amount: ₹${fineAmount.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.black)),
                              Text(
                                  'Collected Amount: ₹${collectedAmount.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.black)),
                              Text('Due Amount: ₹${dueAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Enter payment amount',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    double enteredAmount =
                                        double.tryParse(value) ?? 0.0;
                                    if (enteredAmount > dueAmount) {
                                      // Display an error message or handle the case as desired
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Entered amount cannot be greater than due amount'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      enteredAmount = dueAmount;
                                    }
                                    paymentAmounts[index] = enteredAmount;
                                    updateTotalDueAmount();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10.0,
                        offset: Offset(0, -2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₹${totalDueAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle payment button action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: Text(
                          'Pay',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  }
}