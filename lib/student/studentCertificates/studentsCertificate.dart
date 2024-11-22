import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../views/webview_screen.dart';

class StudentCertificates extends StatefulWidget {
  const StudentCertificates({super.key});

  @override
  State<StudentCertificates> createState() => _StudentCertificatesState();
}

class _StudentCertificatesState extends State<StudentCertificates> {
  List<dynamic> certificatesList = [];
  List<dynamic> certificateMainDisplayList = [];
  List<int> selectedCertificates = [];
  Map<int, TextEditingController> descriptionControllers = {};

  // Added variable to store selected payment type
  int selectedPaymentType = 1; // 1 for Paytm, 2 for Billdesk

  @override
  void initState() {
    super.initState();
    fetchCertificateData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionDialog();
    });
  }

  void _showInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text(
            'Please select the certificates you want to pay for by tapping on the list items. After selection, choose your preferred payment method and click the "Pay for Selected Certificates" button to proceed with the payment.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchCertificateData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studId = prefs.getString('studId') ?? '';

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CertificatesDropdownWithFee'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {"GrpCode": "BEESdev", "ColCode": "0001", "StudentId": studId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        certificatesList = data['certificatesList'];
        certificateMainDisplayList = data['certificateMainDisplayList'];
      });
    } else {
      print('Failed to load data');
    }
  }

  void toggleCertificateSelection(int reportId) {
    setState(() {
      if (selectedCertificates.contains(reportId)) {
        selectedCertificates.remove(reportId);
        descriptionControllers.remove(reportId);
      } else {
        selectedCertificates.add(reportId);
        descriptionControllers[reportId] = TextEditingController();
      }
    });
  }

  bool _canProceedToPayment() {
    if (selectedCertificates.isEmpty) return false;
    for (var certificateId in selectedCertificates) {
      if (descriptionControllers[certificateId]?.text?.isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }


  Future<void> payForSelectedCertificates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    String generateRandomCaptcha(int length) {
      const String characters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      final Random random = Random();
      return List.generate(
          length, (index) => characters[random.nextInt(characters.length)])
          .join();
    }

    if (selectedCertificates.isEmpty) {
      // Optionally, inform the user that no certificates are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No certificates selected for payment.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Determine PaymentType based on user selection
    final int paymentType = selectedPaymentType; // 1 for Paytm, 2 for Billdesk

    // Prepare the StudentCertificatesTableVariable
    List<Map<String, dynamic>> studentCertificates = selectedCertificates.map((id) {
      // Find the certificate by reportId
      final certificate = certificatesList.firstWhere(
            (cert) => cert['reportId'] == id,
        orElse: () => {},
      );

      // Extract the fee, default to '0' if not found
      final dynamic feeDynamic = certificate['fee'];
      // Handle different possible types for fee (e.g., String, int, double)
      double feeDouble;
      if (feeDynamic is String) {
        feeDouble = double.tryParse(feeDynamic) ?? 0.0;
      } else if (feeDynamic is num) {
        feeDouble = feeDynamic.toDouble();
      } else {
        feeDouble = 0.0;
      }

      // Convert decimal to int by truncating, then to string
      final int feeInt = feeDouble.toInt();
      final String feeStr = feeInt.toString();

      return {
        "Id": "0",
        "CertificateId": id.toString(),
        "Purpose": descriptionControllers[id]?.text.trim() ?? '',
        "Fee": feeStr,
      };
    }).toList();

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "StudentId": studId,
      "CertificateId": "0",
      "PaymentDt": "2024-11-19",
      "CaptchaImg": generateRandomCaptcha(6),
      "AcYear":acYear,
      "PayAmount": "1",
      "LoginIpAddress": "", // Consider populating this if available
      "LoginSystemName": "", // Consider populating this if available
      "UserId": "1",
      "Flag": "CREATE",
      "PaymentType": paymentType,
      "StudentCertificatesTableVariable": studentCertificates,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SavingOfCertificatesFeeForTempData'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Payment Success: $data');
        handlePaymentResponse(data, paymentType);
      } else {
        print('Payment failed with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('An error occurred during payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  void handlePaymentResponse(Map<String, dynamic> response, int paymentType) {
    // Print the entire response to understand its structure
    print("Full response: $response");

    if (paymentType == 1) {
      // Handle Paytm Response
      if (response.containsKey('certificatesFeeForTempDataList') &&
          response['certificatesFeeForTempDataList'] is List &&
          response['certificatesFeeForTempDataList'].isNotEmpty) {
        final paymentData = response['certificatesFeeForTempDataList'][0];

        final txnToken = paymentData['paytmResponse']['body']['txnToken'];
        final ordeR_ID = paymentData['ordeR_ID'];
        final callbacK_URL = paymentData['callbacK_URL'];
        final mid = paymentData['productID'];
        final totalAmount = paymentData['amount']?.toDouble() ?? 0.0;
        final newTxnId = paymentData['newTransactionId'];
        final atomTransId = paymentData['atomTransId'];
        print(txnToken);
        print(ordeR_ID);
        print(callbacK_URL);
        print(mid);
        print(totalAmount);
        print(newTxnId);
        print(atomTransId);

        _startTransaction(
          txnToken,
          ordeR_ID,
          callbacK_URL,
          mid,
          totalAmount,
          atomTransId,
        );
      } else {
        print("No payment data found in the response.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No payment data found.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (paymentType == 2) {
      // Handle Billdesk Response
      if (response.containsKey('objectid') &&
          response['objectid'] == 'order' &&
          response.containsKey('orderid')) {
        final bdOrderId = response['bdorderid'];
        final mercId = response['mercid'];
        final rData = response['links'][1]['parameters']['rdata'];

        print('Billdesk Order ID: $bdOrderId');
        print('Merchant ID: $mercId');
        print('RData: $rData');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              bdorderid: bdOrderId.toString(),
              mercid: mercId.toString(),
              rdata: rData.toString(),
              initialUrl: "",
            ),
          ),
        );
      } else {
        print("No valid Billdesk payment data found in the response.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No valid Billdesk payment data found.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startTransaction(
      String txnToken,
      String ordeR_ID,
      String callbacK_URL,
      String mid,
      double totalAmount,
      String atomTransId,
      ) async {
    try {
      final response = await AllInOneSdk.startTransaction(
        mid,
        ordeR_ID,
        totalAmount.toString(),
        txnToken,
        callbacK_URL,
        false,
        false, // restrictAppInvoke
      );

      Map<String, dynamic> sdkResponse;
      if (response is String) {
        sdkResponse = json.decode(response as String);
      } else if (response is Map) {
        sdkResponse = Map<String, dynamic>.from(response);
      } else {
        throw Exception("Unexpected response format");
      }

      // Print all response data
      print("Response from SDK:");
      sdkResponse.forEach((key, value) {
        print("$key: $value");
      });

      // Check if the transaction was successful
      if (sdkResponse['STATUS'] == 'TXN_SUCCESS') {
        // Show a success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally, you can refresh the applied certificates list
        fetchCertificateData();
      } else {
        // Handle unsuccessful transaction if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction Failed: ${sdkResponse['RESPMSG']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on PlatformException catch (e) {
      // Handle specific case where the transaction is canceled
      if (e.code == "0" &&
          e.details['response'] == "Transaction has been canceled") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction has been canceled by the user.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Handle any other PlatformException errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during transaction: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any other errors that occur during the transaction
      print("Error during transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Student Certificates',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 1,
      ),
      body: certificatesList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Selection

            Divider(),
            // Certificates Selection
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: certificatesList.length,
              itemBuilder: (context, index) {
                final certificate = certificatesList[index];
                final isSelected = selectedCertificates
                    .contains(certificate['reportId']);

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                    isSelected ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color:
                      isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]
                        : [
                      BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.school_outlined,
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.blue.shade400,
                        ),
                        title: Text(
                          certificate['reportName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        subtitle: Text(
                          "Fee: ₹${certificate['fee']}",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () {
                          toggleCertificateSelection(
                              certificate['reportId']);
                        },
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextField(
                            controller:
                            descriptionControllers[
                            certificate['reportId']],
                            decoration: InputDecoration(
                              labelText: 'Enter Purpose',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.edit_note),
                            ),
                            onChanged: (value) {
                              // Trigger state update on text change
                              setState(() {});
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            // Pay Button

            if (selectedCertificates.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            RadioListTile<int>(
              secondary: Image.asset(
                'assets/Paytm-Logo.wine.png', // Ensure this path is correct
                width: 100,
                height: 100,

              ),
              title: const Text('Paytm'),
              value: 1,
              groupValue: selectedPaymentType,
              onChanged: (int? value) {
                setState(() {
                  selectedPaymentType = value!;
                });
              },
            ),
            RadioListTile<int>(
              secondary: Image.asset(
                'assets/BillDesk Logo - PNG Logo Vector Brand Downloads (SVG, EPS).png', // Ensure this path is correct
                width: 100,
                height: 100,

              ),
              title: const Text('Billdesk'),
              value: 2,
              groupValue: selectedPaymentType,
              onChanged: (int? value) {
                setState(() {
                  selectedPaymentType = value!;
                });
              },
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, top: 20),
                child: ElevatedButton.icon(
                  onPressed: _canProceedToPayment()
                      ? payForSelectedCertificates
                      : null, // Disable if not valid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Icon(Icons.payment, color: Colors.white),
                  ),
                  label: Center(
                    child: Text(
                      'Pay for Selected Certificates',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            // Divider and Applied Certificates List
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, top: 25, bottom: 10),
              child: Divider(
                height: 10,
                thickness: 2,
                color: Colors.grey.shade300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: Text(
                'Applied Certificate List',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: certificateMainDisplayList.length,
              itemBuilder: (context, index) {
                final certificate = certificateMainDisplayList[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: Colors.grey.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certificate['certificateName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Purpose: ${certificate['purpose']}",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fee: ₹${certificate['fee']}",
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Total: ₹${certificate['totalAmount']}",
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Status: ${certificate['status']}",
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
