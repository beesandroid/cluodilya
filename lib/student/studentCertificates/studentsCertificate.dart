import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

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
            'Please select the certificates you want to pay for by tapping on the list items. After selection, click the "Pay for Selected Certificates" button to proceed with the payment.',
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
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/CertificatesDropdownWithFee'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"GrpCode": "BEES", "ColCode": "0001"}),
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
    for (var certificateId in selectedCertificates) {
      if (descriptionControllers[certificateId]?.text?.isEmpty ?? true) {
        return false;
      }
    }
    return true;
  }
  Future<void> payForSelectedCertificates() async {
    String generateRandomCaptcha(int length) {
      const characters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      Random random = Random();
      return List.generate(
              length, (index) => characters[random.nextInt(characters.length)])
          .join();
    }

    if (selectedCertificates.isEmpty) return;

    final requestBody = jsonEncode({
      "GrpCode": "BEES",
      "ColCode": "0001",
      "StudentId": "102",
      "CertificateId": "0",
      "PaymentDt": "2024-08-22",
      "CaptchaImg": generateRandomCaptcha(6),
      "AcYear": "2024 - 2025",
      "PayAmount": "4",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "UserId": "1",
      "Flag": "CREATE",
      "StudentCertificatesTableVariable": selectedCertificates.map((id) {
        final certificate = certificatesList
            .firstWhere((cert) => cert['reportId'] == id, orElse: () => {});
        return {
          "Id": "0",
          "CertificateId": id.toString(),
          "Purpose": descriptionControllers[id]?.text ?? '',
          "Fee": '${certificate['fee'] ?? '0'}'
          // Adjust this to match your fee logic
        };
      }).toList()
    });

    // Print the request body
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SavingOfCertificatesFeeForTempData'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Payment Success: ${data['certificatesFeeForTempDataList']}');
      handlePaymentResponse(data);

      // Handle successful payment (e.g., navigate, show message)
    } else {
      print('Payment failed');
    }
  }

  void handlePaymentResponse(Map<String, dynamic> response) {
    // Print the entire response to understand its structure
    print("Full response: $response");

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
    }
  }

  Future<void> _startTransaction(
    String txnToken,
    String ordeR_ID,
    String callbacK_URL,
    String mid,
    double totalAmount,
    String atomTransId,
  ) async
  {
    try {
      // Start the transaction and await the response
      final response = await AllInOneSdk.startTransaction(
        mid,
        ordeR_ID,

        totalAmount.toString(),
        txnToken,
        callbacK_URL,
        false,
        // restrictAppInvoke
        false, // restrictAppInvoke
      );

      Map<String, dynamic> sdkResponse;
      if (response is String) {
        sdkResponse = json.decode(response as String); // Decode JSON if response is a String
      } else if (response is Map) {
        sdkResponse = Map<String, dynamic>.from(response); // Ensure it's a Map<String, dynamic>
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
      if (e.code == "0" && e.details['response'] == "Transaction has been canceled") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction has been canceled by the user.'),
            backgroundColor: Colors.orange ,
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
    return
      Scaffold(
        appBar: AppBar(

          title: Text(
            'Student Certificates',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: certificatesList.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      color: isSelected
                          ? Colors.blue.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey.shade300,
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
                              controller: descriptionControllers[
                              certificate['reportId']],
                              decoration: InputDecoration(
                                labelText: 'Enter Purpose',
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
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
              if (selectedCertificates.isNotEmpty)
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
                    margin:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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

