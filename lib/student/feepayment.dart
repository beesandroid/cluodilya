import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

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
        totalAmount = calculateTotalAmount();
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
      List<Map<String, dynamic>> fees = List<Map<String, dynamic>>.from(data['cloudilyaStudentRegularFeeDetailsList']);
      return fees;
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  double calculateTotalAmount() {
    if (feeData == null) return 0.0;
    double total = 0.0;

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      final feeDueAmount = fee['dueAmount'] ?? 0.0;
      final feePayableAmount = double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;
      if (feePayableAmount > feeDueAmount) {
        Fluttertoast.showToast(
          msg: 'Payable amount cannot be greater than due amount.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return total;
      }
      total += feePayableAmount;

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          final installmentDueAmount = fee['installments'][j]['dueAmount'];
          final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;

          if (installmentPayableAmount > installmentDueAmount) {
            Fluttertoast.showToast(
              msg: 'Payable amount cannot be greater than due amount.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            return total;
          }
          total += installmentPayableAmount;
        }
      }
    }
    return total;
  }

  void updateAndPrintTotalAmount() {
    validateAndUpdateTotalAmount(); // Ensure totalAmount is updated
    print('Total Fee: ${totalAmount.toStringAsFixed(2)}');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Payment Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureFees,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No fees data available.'));
          } else {
            final feeData = snapshot.data!;
            print('Full Fee Data: $feeData'); // Debugging print

            return Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: feeData.length,
                      itemBuilder: (context, index) {
                        final fee = feeData[index];
                        final feeName = fee['feeName'];
                        final feeKey = '$index';

                        // Print modifyStatus for debugging
                        final modifyStatus = fee['modifyStatus'];
                        print('Fee Index: $index, Modify Status: $modifyStatus');

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.white,
                            elevation: 4.0,
                            shadowColor: Colors.grey,
                            borderRadius: BorderRadius.circular(12.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feeName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Semester: ${fee['semester']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Amount: ${fee['amount']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Collected Amount: ${fee['collectedAmount']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Due Amount: ${fee['dueAmount']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  const SizedBox(height: 8),
                                  if (fee['installments'] != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: List.generate(
                                        fee['installments'].length,
                                            (installmentIndex) {
                                          final installment = fee['installments'][installmentIndex];
                                          final installmentKey = '$index-$installmentIndex';
                                          final installmentDueAmount = installment['dueAmount'];
                                          final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Installment ${installmentIndex + 1}: ${installment['amount']}',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  'Start Date: ${installment['installmentStartDate']}',
                                                ),
                                                Text(
                                                  'End Date: ${installment['installmentEndDate']}',
                                                ), Text(
                                                  'Due Amount: ${installment['dueAmount']}',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                                                ),
                                                if (installment['modifyStatus'] == 1)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 12.0),
                                                    child: TextField(
                                                      controller: controllers[installmentKey],
                                                      decoration: InputDecoration(
                                                        labelText: 'Payable Amount',
                                                        hintText: 'Enter amount <= $installmentDueAmount',
                                                        border: OutlineInputBorder(),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                      ),
                                                      keyboardType: TextInputType.number,
                                                      onChanged: (value) {
                                                        if (value.isEmpty) {
                                                          controllers[installmentKey]?.text = '0.0';
                                                        }
                                                        validateAndUpdateTotalAmount();
                                                      },
                                                    ),
                                                  )
                                                else
                                                  Text(
                                                    'Payable Amount: $installmentDueAmount',
                                                  ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  if (fee['installments'] == null || fee['installments'].isEmpty)
                                    if (fee['modifyStatus'] == 0)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: controllers[feeKey],
                                          decoration: InputDecoration(
                                            labelText: 'Payable Amount',
                                            hintText: 'Enter amount <= ${fee['dueAmount']}',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            validateAndUpdateTotalAmount();
                                          },
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Payable Amount: ${fee['dueAmount']}'),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            width: 220.0, height: 50,// Set the width
            child: ElevatedButton(
              onPressed: () => _showPaymentPreview(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set the background color to blue
              ),
              child: Text("Proceed to Payment",style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),

    );
  }

  void debugTotalCalculation() {
    double totalPreview = 0.0;

    print('Calculating Total Amount...');
    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      if (fee['modifyStatus'] == 1) {
        final payableAmount = double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;
        print('Fee Key for Preview: $feeKey, Payable Amount: $payableAmount');
        totalPreview += payableAmount;

        if (fee['installments'] != null) {
          for (int j = 0; j < fee['installments'].length; j++) {
            final installmentKey = '$i-$j';
            final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;
            print('Installment Key for Preview: $installmentKey, Payable Amount: $installmentPayableAmount');
            totalPreview += installmentPayableAmount;
          }
        }
      }
    }

    print('Total Amount in Preview: ${totalPreview.toStringAsFixed(2)}');
    print('Displayed Total Amount: ${totalAmount.toStringAsFixed(2)}');
  }

  void validateAndUpdateTotalAmount() {
    if (feeData == null) return;

    double total = 0.0;

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      final payableAmount = double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;
      final dueAmount = fee['dueAmount'];

      if (payableAmount > dueAmount) {
        Fluttertoast.showToast(
          msg: 'Payable amount cannot be greater than due amount.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      total += payableAmount;

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          final installmentDueAmount = fee['installments'][j]['dueAmount'];
          final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;

          if (installmentPayableAmount > installmentDueAmount) {
            Fluttertoast.showToast(
              msg: 'Payable amount cannot be greater than due amount.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            return;
          }
          total += installmentPayableAmount;
        }
      }
    }

    setState(() {
      totalAmount = total;
    });
  }

  void _showPaymentPreview(BuildContext context) {
    final payableFees = <String, double>{};
    double totalAmount = 0.0;

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';
      final feeName = fee['feeName'];
      final feeDueAmount = fee['dueAmount'] ?? 0.0;
      final feePayableAmount = double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;

      if (fee['installments'] != null && fee['installments'].isNotEmpty) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;
          if (installmentPayableAmount > 0) {
            payableFees['Installment ${j + 1} of ${feeName}'] = installmentPayableAmount;
            totalAmount += installmentPayableAmount;
          }
        }
      } else {
        if (feePayableAmount > 0) {
          payableFees[feeName] = feePayableAmount;
          totalAmount += feePayableAmount;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Preview', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...payableFees.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              )),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              processOnlinePayment();



            },
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  void updateTotalAmount() {
    double totalAmountInPreview = 0.0;

    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final modifyStatus = fee['modifyStatus'] ?? 0; // Get modify status
      final feeKey = '$i';
      final payableAmount = double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;

      if (modifyStatus == 1) {
        totalAmountInPreview += payableAmount;

        // Handle installments if any
        if (fee['installments'] != null) {
          for (int j = 0; j < fee['installments'].length; j++) {
            final installmentKey = '$i-$j';
            final installmentPayableAmount = double.tryParse(controllers[installmentKey]?.text ?? '0.0') ?? 0.0;
            totalAmountInPreview += installmentPayableAmount;
          }
        }
      }
    }

    setState(() {
      totalAmount = totalAmountInPreview; // Set the correct total amount
    });

    print('Updated Total Amount: ${totalAmount.toStringAsFixed(2)}');
  }
  Future<void> processOnlinePayment() async {
    const String url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SavingForRegularFeeCollectionTemp';

    const letters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();

    String generateRandomWord(int length) {
      return String.fromCharCodes(
        Iterable.generate(
          length,
              (_) => letters.codeUnitAt(random.nextInt(letters.length)),
        ),
      );
    }

    var captcha = generateRandomWord(6);
    print(captcha);

    // Prepare the request body based on the fee details
    final requestBody = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "ReceiptNumber": 0,
      "ReceiptDate": DateTime.now().toIso8601String().split('T')[0],
      "UserTypeName": "STUDENT",
      "HallTicketNo": "22H41AO485",
      "AcYear": "2024 - 2025",
      "PayAmount": "1",
      "TotalInWords": "one rupee only", // You need to convert the total amount to words
      "CaptchaImg": captcha.toString(),
      "FinYear": "2024 - 2025",
      "Id": "0",
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "CREATEAUTOMATIC",
      "ARSavingForRegularFeeCollectionTempTableVariable": [] // Initialize as an empty list
    };

    // Adding the fee data to the request body
    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installment = fee['installments'][j];
          final installmentKey = '$i-$j';

          (requestBody["ARSavingForRegularFeeCollectionTempTableVariable"] as List).add({
            "AcYear": fee['acYear'],
            "FeeId": fee['feeId'].toString(),
            "FeeName": fee['feeName'].toString(), // Add fee name
            "SourceSystem": fee['sourceSystem'],
            "StartDate": installment['installmentStartDate'], // Correct start date for installment
            "EndDate": installment['installmentEndDate'], // Correct end date for installment
            "Amount": installment['amount'].toString(),
            "CollectedAmount": installment['collectedAmount'].toString(),
            "DueAmount": installment['dueAmount']?.toString() ?? '0',
            "Fine": installment['fine']?.toInt() ?? 0,
            "AmountTobePaid": controllers[installmentKey]?.text ?? installment['dueAmount']?.toString() ?? '0',
          });
        }
      }

      // Add the fee itself if it doesn't have installments or after processing its installments
      if (fee['installments'] == null || fee['installments'].isEmpty) {
        (requestBody["ARSavingForRegularFeeCollectionTempTableVariable"] as List).add({
          "AcYear": fee['acYear'],
          "FeeId": fee['feeId'].toString(),
          "FeeName": fee['feeName'].toString(), // Add fee name
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

    print("Request Body: $requestBody");

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
        final mid = responseData['regularFeeCollectionList'][0]['mid'];
        final newTxnId = responseData['regularFeeCollectionList'][0]['newTxnId'];
        final captchaImg = responseData['regularFeeCollectionList'][0]['captchaImg'];
        final atomTransId = responseData['regularFeeCollectionList'][0]['atomTransId'];

        print('txnToken: $txnToken');
        print('ordeR_ID: $ordeR_ID');
        print('callbacK_URL: $callbacK_URL');
        print('mid: $mid');
        print('newTxnId: $newTxnId');
        print('captchaImg: $captchaImg');
        print('atomTransId: $atomTransId');

        // Pass the totalAmount to _startTransaction
        _startTransaction(txnToken, ordeR_ID, callbacK_URL, mid, totalAmount, newTxnId, captchaImg, atomTransId);
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
      String txnToken,
      String ordeR_ID,
      String callbacK_URL,
      String mid,
      double totalAmount,
      int newTxnId,
      String captchaImg,
      String atomTransId
      ) async {
    try {
      // Start the transaction and await the response
      final response = await AllInOneSdk.startTransaction(
        mid,
        ordeR_ID,
        totalAmount.toString(),
        txnToken,
        callbacK_URL,
        false,
        false, // restrictAppInvoke
      );

      // Handle response
      Map<String, dynamic> sdkResponse;
      if (response is String) {
        sdkResponse = json.decode(response as String); // Decode JSON if response is a String
      } else if (response is Map) {
        sdkResponse = Map<String, dynamic>.from(response); // Ensure it's a Map<String, dynamic>
      } else {
        throw Exception("Unexpected response format");
      }

      // Handle the successful transaction response
      print("Response from SDK: $sdkResponse");

      // Prepare data for API call
      final apiRequestData = {
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "StudentId": "2548",
        "NewTxnId": newTxnId.toString(),
        "CaptchaImg": captchaImg.toString(),
        "AcYear": "2024 - 2025",
        "Id": "0",
        "FinYear": "2024 - 2025",
        "AtomTransId": atomTransId,
        "MerchantTransId": sdkResponse["MID"] ?? "",
        "TransAmt": sdkResponse["TXNAMOUNT"] ?? "",
        "TransSurChargeAmt": "0",
        "TransDate": DateTime.now().toIso8601String().split('T')[0],
        "BankTransId": sdkResponse["BANKTXNID"] ?? "",
        "TransStatus": sdkResponse["STATUS"] ?? "",
        "BankName": "", // Placeholder
        "PaymentDoneThrough": sdkResponse["PAYMENTMODE"] ?? "",
        "CardNumber": "", // Placeholder
        "CardHolderName": "", // Placeholder
        "Email": "siva@gmail.com",
        "Address": "", // Placeholder
        "TransDescription": sdkResponse["STATUS"] ?? "",
        "MobileNo": "4556789876",
        "TxnId": sdkResponse["TXNID"] ?? "", // Adjust if needed
        "Success": "0",
      };

      print("API Request Data: ${json.encode(apiRequestData)}"); // Print API request data

      // Call the API
      final apiUrl = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveRegularFeeMainData';
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(apiRequestData),
      );

      print("API Response Status Code: ${apiResponse.statusCode}"); // Print status code
      print("API Response Body: ${apiResponse.body}"); // Print response body

      // Handle API response
      if (apiResponse.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FeePaymentScreen()),
        );
        Fluttertoast.showToast(
          msg: "Fee data saved successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to save fee data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

    } catch (error) {
      // Handle any errors that occur during the transaction
      print('Error: $error');
      setState(() {
        result = error.toString();
      });

      if (error is PlatformException) {
        Fluttertoast.showToast(
          msg: "PlatformException: ${error.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${error.toString()}",
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
