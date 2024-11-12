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
  bool isEditing = false;
  String? editedFeeId;
  TextEditingController amountController = TextEditingController();
  String? selectedAcademicYear;
  String? selectedFeeName;
  double? maxAmount;
  double? enteredAmount;
  DateTime? fromDate;
  DateTime? toDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchFeePermissions();
    _fetchAcademicYears();
  }

  Future<void> _fetchFeePermissions() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeePermissionsDisplay';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
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
      print(response.body);
      setState(() {
        feePermissionList =
            jsonDecode(response.body)['feePermissionList'] ?? [];
      });
    } else {
      print('Failed to load fee permissions');
    }
  }

  Future<void> _fetchAcademicYears() async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/AcademicYearDropDown';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "AcYear": selectedAcademicYear.toString(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        academicYears =
            jsonDecode(response.body)['academicYearDropDownList'] ?? [];
      });
    } else {
      print('Failed to load academic years');
    }
  }
  Future<void> _fetchFeeNames(String academicYear) async {
    const url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeeNameDropdownNew';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "BEESdev",
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
          final selectedFee = feeNames.firstWhere(
            (fee) => fee['feeName'] == selectedFeeName,
            orElse: () => {'feeId': 0},
          );
          final feeId = isEditing
              ? editedFeeId
              : (selectedFee['feeId'] as int).toString();
          final requestBody = {
            "GrpCode": "Beesdev",
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
            "Flag": isEditing ? "OVERWRITE" : "CREATE",
          };
          print('Request Body: ${jsonEncode(requestBody)}');
          final url =
              'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeePermissionsDisplay';
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
              _fetchFeePermissions();
              setState(() {
                isEditing = false;
                editedFeeId = null;
              });
            }
          } else {
            print('Failed to submit amount');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('PermissionUpTo must be after the PermissionDate')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Entered amount is invalid or exceeds the allowed amount')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  Future<void> _editPermission(Map<String, dynamic> item) async {
    setState(() {
      selectedAcademicYear = item['acYear'];
      isEditing = true;
      editedFeeId = item['feeId'].toString();
    });

    await _fetchFeeNames(selectedAcademicYear!);

    setState(() {
      selectedFeeName = item['feeName'];

      final fee = feeNames.firstWhere(
        (fee) => fee['feeName'] == selectedFeeName,
        orElse: () => {'amount': 0.0},
      );

      maxAmount = fee['amount'] is String
          ? double.tryParse(fee['amount']) ?? 0.0
          : fee['amount'] ?? 0.0;

      enteredAmount =
          double.tryParse(item['permissionAmount'].toString()) ?? 0.0;

      amountController.text = enteredAmount.toString();

      try {
        fromDate = DateFormat('dd-MM-yyyy').parse(item['permissionDate']);
        toDate = DateFormat('dd-MM-yyyy').parse(item['permissionUpTo']);
      } catch (e) {
        print('Error parsing dates: $e');
        fromDate = DateTime.now();
        toDate = DateTime.now();
      }
    });
  }

  void _deletePermission(Map<String, dynamic> item) async {
    final feeId = item['feeId'].toString();
    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "AcYear": item['acYear'],
      "StudentId": "1648",
      "FeeId": feeId,
      "PermissionDate": item['permissionDate'],
      "PermissionAmount": item['permissionAmount'].toString(),
      "PermissionUpTo": item['permissionUpTo'],
      "UserId": "1",
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": "DELETE",
    };

    final url =
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeePermissionsDisplay';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody);
      final message = responseBody['message'] ?? '';
      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      _fetchFeePermissions();
    } else {
      print('Failed to delete permission');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate =
        isFromDate ? fromDate ?? DateTime.now() : toDate ?? DateTime.now();
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

  Widget _buildDetailRow(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Fee Permissions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedAcademicYear,
                    hint: const Text('   Select Academic Year',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    dropdownColor: Colors.blue,
                    items: academicYears
                        .map<DropdownMenuItem<String>>((dynamic year) {
                      return DropdownMenuItem<String>(
                        value: year['acYear'] as String?,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            year['acYear'] as String? ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAcademicYear = value;
                        _fetchFeeNames(value!);
                      });
                    },
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFeeName,
                    hint: const Text('   Select Fee Name',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    dropdownColor: Colors.blue[100],
                    items:
                        feeNames.map<DropdownMenuItem<String>>((dynamic fee) {
                      return DropdownMenuItem<String>(
                        value: fee['feeName'] as String?,
                        child: Text(
                          '  ${fee['feeName'] as String? ?? 'N/A'} - ₹ ${(fee['amount'] as double? ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ₹ ${maxAmount?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
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
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(
                        fromDate != null
                            ? 'From Date: ${dateFormat.format(fromDate!)}'
                            : 'Select From Date',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(
                        toDate != null
                            ? 'To Date: ${dateFormat.format(toDate!)}'
                            : 'Select To Date',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ElevatedButton(
                onPressed: _submitAmount,
                child: const Text(
                  'Submit Amount',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Existing Permissions ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feePermissionList.length,
              itemBuilder: (context, index) {
                final item = feePermissionList[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(5.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 30,
                      child: Icon(Icons.payment, size: 30, color: Colors.blue),
                    ),
                    title: Text(
                      item['feeName'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildDetailRow(
                        icon: Icons.currency_rupee,
                        label: 'Permission Amount',
                        value:
                            '₹ ${item['permissionAmount']?.toStringAsFixed(2) ?? '0.00'}',
                        color: Colors.green,
                      ),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Permission Date',
                        value: item['permissionDate'] ?? 'N/A',
                        color: Colors.blueAccent,
                      ),
                      _buildDetailRow(
                        icon: Icons.update,
                        label: 'Permission Up To',
                        value: item['permissionUpTo'] ?? 'N/A',
                        color: Colors.orange,
                      ),
                      _buildDetailRow(
                        icon: Icons.school,
                        label: 'Academic Year',
                        value: item['acYear'] ?? 'N/A',
                        color: Colors.purple,
                      ),
                    ],
                    trailing: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'Edit') {
                          _editPermission(item);
                        } else if (value == 'Delete') {
                          _deletePermission(item);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'Edit',
                          child: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.blueAccent),
                              SizedBox(width: 10),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
