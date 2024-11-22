import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({Key? key}) : super(key: key);

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _filePath;
  List<dynamic> _leaveRequestList = [];
  int? _editRequestId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRequests();
  }

  Future<void> _fetchLeaveRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String studId = prefs.getString('studId') ?? '';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": grpCode,
          "ColCode": colCode,
          "CollegeId": "1",
          "Id": "0",
          "StudentId": studId,
          "EmployeeId": "0",
          "Description": "",
          "Subject": "",
          "RequestDate": "2024-08-12",
          "FromDate": "",
          "ToDate": "",
          "File": "",
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "VIEW"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data); // Log the complete response

        // Check if 'studentLeaveRequestList' exists and is a list
        if (data['studentLeaveRequestList'] != null &&
            data['studentLeaveRequestList'] is List) {
          setState(() {
            _leaveRequestList = data['studentLeaveRequestList'];
          });
        } else {
          setState(() {
            _leaveRequestList = []; // Handle case where there are no requests
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No leave requests found')),
          );
        }
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load leave requests')),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendLeaveRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String photo = prefs.getString('photo') ?? '';
    String imagePath = prefs.getString('imagePath') ?? '';
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String password = prefs.getString('password') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegename = prefs.getString('collegename') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String groupUserId = prefs.getString('groupUserId') ?? '';
    String hostelUserId = prefs.getString('hostelUserId') ?? '';
    String transportUserId = prefs.getString('transportUserId') ?? '';
    String adminUserId = prefs.getString('adminUserId') ?? '';
    String empId = prefs.getString('empId') ?? '';
    String databaseCode = prefs.getString('databaseCode') ?? '';
    String description = prefs.getString('description') ?? '';
    String dateDifference = prefs.getString('dateDifference') ?? '';
    String userType = prefs.getString('userType') ?? '';
    String acYear = prefs.getString('acYear') ?? '';
    String finYear = prefs.getString('finYear') ?? '';
    String email = prefs.getString('email') ?? '';
    String studentStatus = prefs.getString('studentStatus') ?? '';
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _fromDate == null ||
        _toDate == null ||
        _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    final flag = _editRequestId == null ? "CREATE" : "OVERWRITE";
    final requestId = _editRequestId ?? 0;

    final requestBody = {
      "GrpCode": grpCode,
      "ColCode": colCode,
      "CollegeId": "1",
      "Id": requestId,
      "StudentId": studId,
      "EmployeeId": "0",
      "RequestDate": "2024-08-12",
      "Description": _descriptionController.text,
      "Subject": _subjectController.text,
      "FromDate": _fromDate?.toIso8601String(),
      "ToDate": _toDate?.toIso8601String(),
      "File": _filePath,
      "LoginIpAddress": "",
      "LoginSystemName": "",
      "Flag": flag
    };

    // Print request body
    print('Request Body: ${json.encode(requestBody)}');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        _fetchLeaveRequests();
        final Map<String, dynamic> responseBody = json.decode(response.body);
        print(responseBody.toString());

        final String message = responseBody['message'] ?? '';
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _editRequestId = null;
          _subjectController.clear();
          _descriptionController.clear();
          _fromDate = null;
          _toDate = null;
          _filePath = null;
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send leave request')),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while sending request')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = isFromDate
        ? (_fromDate ?? DateTime.now())
        : (_toDate ??
        (_fromDate != null
            ? _fromDate!.add(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 1))));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _modifyLeaveRequest(int index) {
    final request = _leaveRequestList[index];
    setState(() {
      _editRequestId = request['id'];
      _subjectController.text = request['subject'] ?? '';
      _descriptionController.text = request['description'] ?? '';
      _fromDate = DateTime.tryParse(request['fromDate'] ?? '');
      _toDate = DateTime.tryParse(request['toDate'] ?? '');
      _filePath = request['file'];
    });
  }

  void _confirmDeleteLeaveRequest(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
          const Text('Are you sure you want to delete this leave request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteLeaveRequest(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLeaveRequest(int index) async {
    final request = _leaveRequestList[index];
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentLeaveRequest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "GrpCode": "BeesDEV",
          "ColCode": "0001",
          "CollegeId": "1",
          "Id": request['id'],
          "StudentId": "2548",
          "EmployeeId": "0",
          "Description": "",
          "RequestDate": "2024-08-12",
          "Subject": "",
          "FromDate": "",
          "ToDate": "",
          "File": "",
          "LoginIpAddress": "",
          "LoginSystemName": "",
          "Flag": "DELETE"
        }),
      );

      if (response.statusCode == 200) {
        _fetchLeaveRequests();
        final Map<String, dynamic> responseBody = json.decode(response.body);

        final String message = responseBody['message'] ?? '';
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete leave request')),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while deleting request')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {int maxLines = 1, IconData? icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap,
      {IconData? icon}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                date != null
                    ? "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}"
                    : 'Select Date',
                style: TextStyle(
                  color: date != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.attach_file),
          labelText: 'Attached File',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _filePath != null
                    ? _filePath!.split('/').last
                    : 'No file chosen',
                style: TextStyle(
                  color:
                  _filePath != null ? Colors.black87 : Colors.grey.shade600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.upload_file,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Request',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Input Form Card
                    Card(
                      color: Colors.white, // Set the Card's background color to white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5, // Optional: Adds a shadow for depth
                      shadowColor: Colors.grey.shade300, // Optional: Customize the shadow color
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildTextField(
                              _subjectController,
                              'Subject',
                              icon: Icons.subject,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              _descriptionController,
                              'Description',
                              maxLines: 4,
                              icon: Icons.description,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDatePicker(
                                    'From Date',
                                    _fromDate,
                                        () => _selectDate(context, true),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDatePicker(
                                    'To Date',
                                    _toDate,
                                        () => _selectDate(context, false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildFilePicker(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _sendLeaveRequest,
                                icon: Icon(
                                  _editRequestId == null ? Icons.send : Icons.edit,
                                  color: Colors.white, // Ensure the icon is visible on the button
                                ),
                                label: Text(
                                  _editRequestId == null ? 'Send Request' : 'Modify Request',
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Colors.blue.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Leave Requests List
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Leave Requests",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _leaveRequestList.isEmpty
                        ? Center(
                      child: Text(
                        'No leave requests found.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _leaveRequestList.length,
                      itemBuilder: (context, index) {
                        final request = _leaveRequestList[index];
                        return Card(color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row with Subject and Action Buttons
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        request['subject'] ?? 'No Subject',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.green,
                                          ),
                                          onPressed: () =>
                                              _modifyLeaveRequest(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _confirmDeleteLeaveRequest(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Description
                                Text(
                                  request['description'] ?? 'No Description',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Date Range
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'From: ${request['fromDate'] != null ? request['fromDate'].split('T')[0] : 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'To: ${request['toDate'] != null ? request['toDate'].split('T')[0] : 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // Attached File
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        request['file'] != null
                                            ? request['file'].split('/').last
                                            : 'No file attached',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
            ),
            // Loading Indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
