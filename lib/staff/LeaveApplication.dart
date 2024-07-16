import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'leavemodel.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key});

  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late Future<List<LeaveData>> _leaveData;
  int? _selectedRowIndex;
  String? _selectedAbsenceName;
  String _reason = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  File? _selectedFile;
  String _daysTaken = '';
  String? _selectedPeriodType;
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _leaveData = fetchLeaveData();
  }

  Future<List<LeaveData>> fetchLeaveData() async {
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "2",
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY"
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> jsonList = data['employeeLeavesDisplayList'];
      return jsonList.map((json) => LeaveData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load leave data');
    }
  }

  void _onRowTapped(int index, LeaveData data) {
    setState(() {
      _selectedRowIndex = index;
      _selectedAbsenceName = data.absenceName;

      _reason = '';
      _fromDate = null;
      _toDate = null;
      _selectedFile = null;
      _daysTaken = '';
      _selectedPeriodType = null;
    });
  }

  void _calculateDaysTaken() {
    if (_fromDate != null && _toDate != null) {
      final difference = _toDate!.difference(_fromDate!).inDays;
      setState(() {
        _daysTaken = difference == 0
            ? _selectedPeriodType != null
            ? 'Selected period: $_selectedPeriodType'
            : 'Period not selected'
            : '$difference days';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Application')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<LeaveData>>(
              future: _leaveData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No leave data available'));
                } else {
                  final leaveData = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                      MaterialStateColor.resolveWith((states) => Colors.blue),
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Absence Name', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Accrual Period', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Balance', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Last Accrued Date', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Accrued', style: TextStyle(color: Colors.white))),
                      ],
                      rows: List.generate(leaveData.length, (index) {
                        final data = leaveData[index];
                        final isSelected = _selectedRowIndex == index;
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) =>
                          isSelected
                              ? Colors.blue.withOpacity(0.3) // Background glow effect
                              : Colors.transparent),
                          cells: [
                            _buildDataCell(data.absenceName, index, data),
                            _buildDataCell(data.accrualPeriodName, index, data),
                            _buildDataCell(data.balance.toString(), index, data),
                            _buildDataCell(data.lastAccruedDate, index, data),
                            _buildDataCell(data.accrued.toString(), index, data),
                          ],
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            if (_selectedAbsenceName != null) _buildDetailContainer(),
          ],
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text, int index, LeaveData data) {
    return DataCell(
      InkWell(
        onTap: () => _onRowTapped(index, data),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(text),
        ),
      ),
    );
  }
  Widget _buildDetailContainer() {
    return Material(
      elevation: 44,
      shadowColor: Colors.blue,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Selected Absence: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: _selectedAbsenceName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              style: TextStyle(color: Colors.black87),
              onChanged: (value) {
                setState(() {
                  _reason = value;
                  _validateForm();
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, color: Colors.black87),
                    label: Text(
                      'From Date: ${_fromDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.blueGrey[100],
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _fromDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _fromDate = pickedDate;
                          _calculateDaysTaken();
                          _validateForm();
                        });
                      }
                    },
                  ),
                ),
                Container(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, color: Colors.black87),
                    label: Text(
                      'To Date: ${_toDate?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.blueGrey[100],
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _toDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _toDate = pickedDate;
                          _calculateDaysTaken();
                          _validateForm();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fromDate != null &&
                _toDate != null &&
                _fromDate!.isAtSameMomentAs(_toDate!)) ...[
              const SizedBox(height: 16),
              Text(
                'Select Period:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(width: 220,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSelectablePeriodOption('Full Day'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(width: 220,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSelectablePeriodOption('Afternoon'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(width: 220,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSelectablePeriodOption('Forenoon'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Days Taken: $_daysTaken',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file, color: Colors.black87),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile == null
                            ? 'Choose File'
                            : 'File Selected: ${_selectedFile!.path.split('/').last}',
                        style: TextStyle(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 16),
              Text(
                'Selected File Path: ${_selectedFile!.path}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isSaveButtonEnabled
                      ? () {
                    // Add your save logic here
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _isSaveButtonEnabled ? Colors.blueAccent : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('Adjust'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectablePeriodOption(String period) {
    final isSelected = _selectedPeriodType == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriodType = period;
          _calculateDaysTaken();
          _validateForm();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  void _validateForm() {
    setState(() {
      _isSaveButtonEnabled = _selectedAbsenceName!.isNotEmpty &&
          _reason.isNotEmpty &&
          _fromDate != null &&
          _toDate != null &&
          (_fromDate!.isAtSameMomentAs(_toDate!) ? _selectedPeriodType != null : true);
    });
  }
}
