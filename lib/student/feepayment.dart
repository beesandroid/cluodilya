import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fee Payment Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FeePaymentScreen(),
    );
  }
}

class FeePaymentScreen extends StatefulWidget {
  @override
  _FeePaymentScreenState createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  late Future<List<Map<String, dynamic>>> futureFees;
  List<Map<String, dynamic>>? feeData;
  Map<String, TextEditingController> controllers = {};
  double totalAmount = 0.0;
  late String result = '';

  @override
  void initState() {
    super.initState();
    futureFees = fetchFeeDetails().then((fees) {
      setState(() {
        feeData = fees;
        initializeControllers(fees);
        totalAmount = calculateInitialTotalAmount(fees);
      });
      return fees;
    });
  }

  Future<List<Map<String, dynamic>>> fetchFeeDetails() async {
    const String url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SearchStudentRegularFeeDetails';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "HostelId": "0",
        "ReceiptNumber": "0",
        "HallTicketNo": "22H41AO485",
        "UserTypeName": "Student",
        "FeeSetUpId": "",
        "ReceiptDate": "",
        "Flag": "AR",
        "FeeId": "0"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> fees = List<Map<String, dynamic>>.from(
          data['cloudilyaStudentRegularFeeDetailsList']);
      return fees;
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  void initializeControllers(List<Map<String, dynamic>> fees) {
    for (int i = 0; i < fees.length; i++) {
      final fee = fees[i];
      final feeKey = '$i';
      if (!controllers.containsKey(feeKey)) {
        controllers[feeKey] = TextEditingController(text: fee['dueAmount'].toString());
      }
      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          if (!controllers.containsKey(installmentKey)) {
            controllers[installmentKey] = TextEditingController(text: fee['installments'][j]['dueAmount'].toString());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text('Fee Payment Details'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureFees,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No fee details available.'));
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final fee = snapshot.data![index];
                        final feeKey = '$index';
                        if (!controllers.containsKey(feeKey)) {
                          controllers[feeKey] = TextEditingController(text: fee['dueAmount'].toString());
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(color: Colors.white,
                            elevation: 4.0,
shadowColor: Colors.grey,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${fee['feeName']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Semester: ${fee['semester']}'),
                                  Text('Amount: ${fee['amount']}'),
                                  Text('Collected Amount: ${fee['collectedAmount']}'),
                                  Text('Due Amount: ${fee['dueAmount']}'),
                                  const SizedBox(height: 8),
                                  if (fee['installments'] != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: List.generate(
                                        fee['installments'].length,
                                            (installmentIndex) {
                                          final installment = fee['installments'][installmentIndex];
                                          final installmentKey = '$index-$installmentIndex';
                                          if (!controllers.containsKey(installmentKey)) {
                                            controllers[installmentKey] = TextEditingController(text: installment['dueAmount'].toString());
                                          }
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Installment ${installmentIndex + 1}'),
                                              Text('Installment Due Amount: ${installment['dueAmount']}'),
                                              if (installment['modifyStatus'] == 0)
                                                TextField(
                                                  controller: controllers[installmentKey],
                                                  decoration: InputDecoration(
                                                    labelText: 'Payable Amount',
                                                    hintText: 'Enter amount <= ${installment['dueAmount']}',
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (value) {
                                                    validateAndUpdateTotalAmount();
                                                  },
                                                )
                                              else
                                                Text('Payable Amount: ${installment['dueAmount']}'),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  else if (fee['modifyStatus'] == 0)
                                    TextField(
                                      controller: controllers[feeKey],
                                      decoration: InputDecoration(
                                        labelText: 'Payable Amount',
                                        hintText: 'Enter amount <= ${fee['dueAmount']}',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        validateAndUpdateTotalAmount();
                                      },
                                    )
                                  else
                                    Text('Payable Amount: ${fee['dueAmount']}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total Amount: ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showPaymentPreview(context),
                    child: const Text('Pay',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Space before the bottom of the screen
                ],
              );
            }
          },
        ),
      );
  }


  double calculateInitialTotalAmount(List<Map<String, dynamic>> fees) {
    double total = 0.0;
    for (final fee in fees) {
      if (fee['installments'] != null) {
        for (final installment in fee['installments']) {
          total += installment['dueAmount'];
        }
      } else {
        total += fee['dueAmount'];
      }
    }
    return total;
  }

  void validateAndUpdateTotalAmount() {
    if (feeData == null) return;

    double total = 0.0;

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';
      double totalInstallmentAmount = 0.0;
      double totalInstallmentsDue = 0.0;

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          double installmentDueAmount = fee['installments'][j]['dueAmount'];
          double enteredAmount = double.tryParse(controllers[installmentKey]?.text ?? '0') ?? 0.0;

          if (enteredAmount > installmentDueAmount) {
            enteredAmount = installmentDueAmount;
            controllers[installmentKey]?.text = installmentDueAmount.toString();
          }

          totalInstallmentAmount += enteredAmount;
          totalInstallmentsDue += installmentDueAmount;
        }

        // Adjust remaining installments
        double remainingDueAmount = fee['dueAmount'] - totalInstallmentAmount;
        for (int j = 0; j < fee['installments'].length; j++) {
          if (controllers['$i-$j']?.text == '0') {
            controllers['$i-$j']?.text = remainingDueAmount.toString();
            remainingDueAmount = 0;
            break;
          }
        }

        total += totalInstallmentAmount;
      } else {
        double enteredAmount = double.tryParse(controllers[feeKey]?.text ?? '0') ?? 0.0;
        if (enteredAmount > fee['dueAmount']) {
          enteredAmount = fee['dueAmount'];
          controllers[feeKey]?.text = fee['dueAmount'].toString();
        }
        total += enteredAmount;
      }
    }

    setState(() {
      totalAmount = total;
    });
  }


  void _showPaymentPreview(BuildContext context) {
    List<Widget> feeWidgets = [];

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';
      String feeName = '${fee['feeName']}';
      String acYear = '${fee['acYear']}';
      String feeId = '${fee['feeId']}';
      String sourceSystem = '${fee['sourceSystem']}';
      String startDate = '${fee['startDate']}';
      String endDate = '${fee['endDate']}';
      String collectedAmount = '${fee['collectedAmount']}';
      String dueAmount = '${fee['dueAmount']}';
      String fine = '${fee['fine']}';
      String amountToBePaid = '${fee['amountToBePaid']}';
      String amountEntered = controllers[feeKey]?.text ?? '0';

      feeWidgets.add(Text('$feeName: $amountEntered'));

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          String installmentName = 'Installment ${j + 1}';
          String installmentAmountEntered = controllers[installmentKey]?.text ?? '0';
          feeWidgets.add(Text('$installmentName - $installmentAmountEntered'));
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Preview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: feeWidgets,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Offline'),
            ),
            TextButton(
              onPressed: () async {
                await processOnlinePayment();
                Navigator.of(context).pop();
              },
              child: Text('Online Payment'),
            ),
          ],
        );
      },
    );
  }
  Future<void> processOnlinePayment() async {
    const String url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SavingForRegularFeeCollectionTemp';

    // Prepare the request body based on the fee details
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "ReceiptNumber": 0,
      "ReceiptDate": "2024-07-26",
      "UserTypeName": "STUDENT",
      "HallTicketNo": "22H41AO485",
      "AcYear": "2024 - 2025",
      "PayAmount": totalAmount.toInt(),
      "TotalInWords": "one rupee only", // You need to convert the total amount to words
      "CaptchaImg": "sfgbc",
      "FinYear": "2024 - 2025",
      "Id": "0",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "CREATEAUTOMATIC",
      "ARSavingForRegularFeeCollectionTempTableVariable": [] // Initialize as an empty list
    };

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          (requestBody["ARSavingForRegularFeeCollectionTempTableVariable"] as List).add({
            "AcYear": fee['acYear'],
            "FeeId": fee['feeId'].toString(),
            "SourceSystem": fee['sourceSystem'],
            "StartDate": fee['startDate'],
            "EndDate": fee['endDate'],
            "Amount": fee['amount'].toString(),
            "CollectedAmount": fee['collectedAmount'].toString(),
            "DueAmount": fee['installments'][j]['dueAmount']?.toString() ?? '0',
            "Fine": fee['fine']?.toInt() ?? 0,
            "AmountTobePaid": controllers[installmentKey]?.text ?? fee['installments'][j]['dueAmount']?.toString() ?? '0',
          });
        }
      } else {
        (requestBody["ARSavingForRegularFeeCollectionTempTableVariable"] as List).add({
          "AcYear": fee['acYear'],
          "FeeId": fee['feeId'].toString(),
          "SourceSystem": fee['sourceSystem'],
          "StartDate": fee['startDate'],
          "EndDate": fee['endDate'],
          "Amount": fee['amount'].toString(),
          "CollectedAmount": fee['collectedAmount'].toString(),
          "DueAmount": fee['dueAmount']?.toString() ?? '0',
          "Fine": fee['fine']?.toInt() ?? 0,
          "AmountTobePaid": controllers[feeKey]?.text ?? fee['dueAmount']?.toString() ?? '0',
        });
      }
    }

    print(requestBody);

    try {
      final httpResponse = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (httpResponse.statusCode == 200) {
        // Handle successful payment
        final responseData = jsonDecode(httpResponse.body);
        final paytmResponse = responseData['regularFeeCollectionList'][0]['paytmResponse'];

        final txnToken = paytmResponse['body']['txnToken'];
        final ordeR_ID = responseData['regularFeeCollectionList'][0]['ordeR_ID'];
        final callbacK_URL = responseData['regularFeeCollectionList'][0]['callbacK_URL'];
        final mid = responseData['regularFeeCollectionList'][0]['mid']; // Adjusted location for mid

        print('txnToken: $txnToken');
        print('ordeR_ID: $ordeR_ID');
        print('callbacK_URL: $callbacK_URL');
        print('mid: $mid');

        // Pass the totalAmount to _startTransaction
        _startTransaction(txnToken, ordeR_ID, callbacK_URL, mid, totalAmount);
      } else {
        // Handle payment error
        print('Failed to process payment. Status Code: ${httpResponse.statusCode}');
        print('Response Body: ${httpResponse.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
  Future<void> _startTransaction(
      String txnToken, String ordeR_ID, String callbacK_URL, String mid, double totalAmount) async {
    try {
      // Start the transaction and await the response
      var response = await AllInOneSdk.startTransaction(
        "StMart33073105799254",
        ordeR_ID,
        totalAmount.toString(),
        txnToken,
        callbacK_URL,
        false,
        false, // restrictAppInvoke
      );

      // Handle the successful transaction response
      print("Response from SDK: $response");
      setState(() {
        result = response.toString(); // Include gateway name in result
      });

      // Show a toast indicating successful transaction
      Fluttertoast.showToast(
        msg: "Transaction Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (error) {
      // Handle any errors that occur during the transaction
      print('Error: $error');
      setState(() {
        result = error.toString();
      });

      if (error is PlatformException) {
        Fluttertoast.showToast(
          msg: "Transaction Failed: ${error.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }


}
