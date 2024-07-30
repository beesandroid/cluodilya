import 'dart:math';

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
  Set<String> modifiedFeeKeys = {};

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
    const String url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SearchStudentRegularFeeDetails';
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

  double calculateTotalAmount() {
    if (feeData == null) return 0.0;
    double total = 0.0;
    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          total += double.tryParse(controllers[installmentKey]?.text ??
              '0.0') ??
              0.0; // Use text from controller
        }
      } else {
        total += double.tryParse(controllers[feeKey]?.text ?? '0.0') ?? 0.0;
      }
    }
    return total;
  }

  void initializeControllers(List<Map<String, dynamic>> fees) {
    for (int i = 0; i < fees.length; i++) {
      final fee = fees[i];
      final feeKey = '$i';
      if (!controllers.containsKey(feeKey)) {
        controllers[feeKey] =
            TextEditingController(text: fee['dueAmount'].toString());
      }
      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          if (!controllers.containsKey(installmentKey)) {
            controllers[installmentKey] = TextEditingController(
                text: fee['installments'][j]['dueAmount'].toString());
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
                        controllers[feeKey] = TextEditingController(
                            text: fee['dueAmount'].toString());
                      }

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
                                  '${fee['feeName']}',
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                if (fee['installments'] != null)
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: List.generate(
                                      fee['installments'].length,
                                          (installmentIndex) {
                                        final installment = fee['installments']
                                        [installmentIndex];
                                        final installmentKey =
                                            '$index-$installmentIndex';
                                        if (!controllers
                                            .containsKey(installmentKey)) {
                                          controllers[installmentKey] =
                                              TextEditingController(
                                                  text: installment['dueAmount']
                                                      .toString());
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Installment ${installmentIndex +
                                                    1}'),
                                            Text(
                                                'Installment Due Amount: ${installment['dueAmount']}'),
                                            if (installment['modifyStatus'] == 0)
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: controllers[
                                                  installmentKey],
                                                  decoration: InputDecoration(
                                                    labelText: 'Payable Amount',
                                                    hintText:
                                                    'Enter amount <= ${installment['dueAmount']}',
                                                  ),
                                                  keyboardType:
                                                  TextInputType.number,
                                                  onChanged: (value) {
                                                    validateAndUpdateTotalAmount();
                                                  },
                                                ),
                                              )
                                            else
                                              Text(
                                                  'Payable Amount: ${installment['dueAmount']}'),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                else
                                  if (fee['modifyStatus'] == 0)
                                    TextField(
                                      controller: controllers[feeKey],
                                      decoration: InputDecoration(
                                        labelText: 'Payable Amount',
                                        hintText:
                                        'Enter amount <= ${fee['dueAmount']}',
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
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showPaymentPreview(context),
                  child: const Text(
                    'Pay',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
        },
      ),
    );
  }

  void validateAndUpdateTotalAmount() {
    if (feeData == null) return;

    double total = 0.0;
    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData?[i];
      final feeKey = '$i';
      double totalInstallmentAmount = 0.0;

      if (fee?['installments'] != null) {
        for (int j = 0; j < fee?['installments'].length; j++) {
          final installmentKey = '$i-$j';
          double installmentDueAmount = fee?['installments'][j]['dueAmount'];

          final installmentPayableAmount = double.tryParse(
              controllers[installmentKey]?.text ?? '0.0') ??
              0.0;
          if (installmentPayableAmount > installmentDueAmount) {
            Fluttertoast.showToast(
              msg: 'Payable amount cannot be greater than due amount.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            return;
          }
          totalInstallmentAmount += installmentPayableAmount;
        }
        total += totalInstallmentAmount;
      } else {
        final payableAmount = double.tryParse(controllers[feeKey]?.text ??
            '0.0') ??
            0.0;
        final dueAmount = fee?['dueAmount'];
        if (payableAmount > dueAmount) {
          Fluttertoast.showToast(
            msg: 'Payable amount cannot be greater than due amount.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
        total += payableAmount;
      }
    }

    setState(() {
      totalAmount = total;
    });
  }

  void _showPaymentPreview(BuildContext context) {
    final payableFees = <String, double>{};
    for (int i = 0; i < feeData!.length; i++) {
      final fee = feeData![i];
      final feeKey = '$i';

      if (fee['installments'] != null) {
        for (int j = 0; j < fee['installments'].length; j++) {
          final installmentKey = '$i-$j';
          final installmentPayableAmount = double.tryParse(
              controllers[installmentKey]?.text ?? '0.0') ??
              0.0;
          if (installmentPayableAmount > 0) {
            payableFees[feeKey + '-installment-$j'] = installmentPayableAmount;
          }
        }
      } else {
        final payableAmount = double.tryParse(
            controllers[feeKey]?.text ?? '0.0') ??
            0.0;
        if (payableAmount > 0) {
          payableFees[feeKey] = payableAmount;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...payableFees.entries.map((entry) => Text(
                '${entry.key}: ${entry.value.toStringAsFixed(2)}')),
            SizedBox(height: 16),
            Text('Total: ${totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initiatePayment();
            },
            child: Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _initiatePayment() {
    final orderId = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    final callBackUrl = 'https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$orderId';
    final String merchantId = 'your_merchant_id'; // Replace with your merchant ID
    final String merchantKey = 'your_merchant_key'; // Replace with your merchant key

    final double amount = totalAmount;

    final String txnToken = generateTxnToken();

    var response = AllInOneSdk.startTransaction(
        merchantId, orderId, amount.toStringAsFixed(2), txnToken, callBackUrl,
        false, true);

    response.then((value) {
      setState(() {
        result = value.toString();
      });
    }).catchError((error) {
      if (error is PlatformException) {
        setState(() {
          result = "${error.message} \n  ${error.details}";
        });
      } else {
        setState(() {
          result = error.toString();
        });
      }
    });
  }

  String generateTxnToken() {
    var rng = Random();
    var codeUnits = List.generate(20, (index) {
      return rng.nextInt(33) + 89;
    });

    return String.fromCharCodes(codeUnits);
  }
}
