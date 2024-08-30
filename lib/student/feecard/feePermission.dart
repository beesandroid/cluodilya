import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FeePermission extends StatefulWidget {
  const FeePermission({super.key});

  @override
  State<FeePermission> createState() => _FeePermissionState();
}

class _FeePermissionState extends State<FeePermission> {
  List<dynamic> feePermissionList = [];
  List<dynamic> academicYears = [];
  List<dynamic> feeNames = [];

  String? selectedAcademicYear;
  String? selectedFeeName;
  double? maxAmount;
  double? enteredAmount;

  DateTime? fromDate;
  DateTime? toDate;

  bool _dropdownsVisible = false; // To control dropdown visibility

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Date format

  @override
  void initState() {
    super.initState();
    _fetchFeePermissions();
  }

  Future<void> _fetchFeePermissions() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeePermissionsDisplay';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "AcYear": "2024 - 2025",
        "StudentId": "1648",
        "FeeId": "0",
        "PermissionDate": "",
        "PermissionAmount": "0",
        "PermissionUpTo": "",
        "UserId": "1",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW",
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        feePermissionList = jsonDecode(response.body)['feePermissionList'] ?? [];
      });
    } else {
      print('Failed to load fee permissions');
    }
  }

  Future<void> _fetchAcademicYears() async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AcademicYearDropDown';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "AcYear":selectedAcademicYear.toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        academicYears = jsonDecode(response.body)['academicYearDropDownList'] ?? [];
        _dropdownsVisible = true; // Make dropdowns visible after loading
      });
    } else {
      print('Failed to load academic years');
    }
  }

  Future<void> _fetchFeeNames(String academicYear) async {
    const url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeeNameDropdownNew';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "BEES",
        "ColCode": "0001",
        "AcYear": academicYear,
        "StudentId": "1648",
        "FeeId": "0",
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        feeNames = jsonDecode(response.body)['feeNameDropdownNewList'] ?? [];
      });
    } else {
      print('Failed to load fee names');
    }
  }

  Future<void> _submitAmount() async {
    if (enteredAmount != null) {
      if (enteredAmount! > 0 && enteredAmount! <= (maxAmount ?? 0)) {
        if (fromDate != null && toDate != null && toDate!.isAfter(fromDate!)) {
          // Extract the fee ID from selectedFeeName
          final selectedFee = feeNames.firstWhere(
                (fee) => fee['feeName'] == selectedFeeName,
            orElse: () => {'feeId': 0}, // Default to 0 if not found
          );
          final feeId = (selectedFee['feeId'] as int).toString(); // Ensure feeId is a String

          // Prepare the request body
          final requestBody = {
            "GrpCode": "Bees",
            "ColCode": "0001",
            "AcYear": selectedAcademicYear.toString(),
            "StudentId": "1648",
            "FeeId": feeId,
            "PermissionDate": dateFormat.format(fromDate!),
            "PermissionAmount": enteredAmount?.toStringAsFixed(2),
            "PermissionUpTo": dateFormat.format(toDate!),
            "UserId": "1",
            "LoginIpAddress": "",
            "LoginSystemName": "",
            "Flag": "OVERWRITE",
          };

          // Print the request body for debugging
          print('Request Body: ${jsonEncode(requestBody)}');

          final url = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeePermissionsDisplay';
          final response = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            final message = responseBody['message'] ?? '';
            if (message.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            } else {
              // Refresh the screen
              _fetchFeePermissions();
            }
          } else {
            print('Failed to submit amount');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PermissionUpTo must be after the PermissionDate')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entered amount is invalid or exceeds the allowed amount')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = isFromDate ? fromDate ?? DateTime.now() : toDate ?? DateTime.now();
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime(DateTime.now().year + 10);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: const Text('Fee Permissions',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _fetchAcademicYears,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8), // Space between the icon and the text
                      const Text(
                        'Add Permissions',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 16),
            if (_dropdownsVisible) ...[
              DropdownButton<String>(
                value: selectedAcademicYear,
                hint: const Text('Select Academic Year'),
                items: academicYears.map<DropdownMenuItem<String>>((dynamic year) {
                  return DropdownMenuItem<String>(
                    value: year['acYear'] as String?,
                    child: Text(
                      year['acYear'] as String? ?? 'N/A',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAcademicYear = value;
                    _fetchFeeNames(value!);
                  });
                },
                style: const TextStyle(color: Colors.black),

              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedFeeName,
                hint: const Text('Select Fee Name'),
                items: feeNames.map<DropdownMenuItem<String>>((dynamic fee) {
                  return DropdownMenuItem<String>(
                    value: fee['feeName'] as String?,
                    child: Text(
                      '${fee['feeName'] as String? ?? 'N/A'} - ₹ ${(fee['amount'] as double? ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFeeName = value;
                    maxAmount = feeNames.firstWhere(
                          (fee) => fee['feeName'] == value,
                      orElse: () => {'amount': 0.0},
                    )['amount'] as double?;
                  });
                },
                style: const TextStyle(color: Colors.black),

              ),
            ],
            const SizedBox(height: 16),
            if (maxAmount != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount: ₹ ${maxAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        enteredAmount = double.tryParse(value);
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Container(width: 220,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(
                        fromDate != null
                            ? 'From Date: ${dateFormat.format(fromDate!)}'
                            : 'Select From Date',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(width: 220,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        toDate != null
                            ? 'To Date: ${dateFormat.format(toDate!)}'
                            : 'Select To Date',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                ],
              )
,
            const SizedBox(height: 16),
            if (enteredAmount != null)
              ElevatedButton(
                onPressed: _submitAmount,
                child: const Text('Submit Amount',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Existing Permissions ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: feePermissionList.length,
                itemBuilder: (context, index) {
                  final item = feePermissionList[index];
                  return Card(color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child:
                    ListTile(
                      title: Text(
                        item['feeName'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permission Amount: ₹ ${item['permissionAmount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Original Amount: ₹ ${item['originalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(color: Colors.black),
                          ),

                          Text(
                            'Due Amount: ₹ ${item['dueAmount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Permission Date: ${item['permissionDate'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Permission Up To: ${item['permissionUpTo'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Academic Year: ${item['acYear'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    )

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
