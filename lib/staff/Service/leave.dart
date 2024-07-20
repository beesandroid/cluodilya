import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveService {
  final String _baseUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves';

  Future<List<dynamic>> fetchLeaveTypes() async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "GrpCode": "bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "1",
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY",
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['employeeLeavesDisplayList'] as List<dynamic>;
    } else {
      throw Exception('Failed to load leave types');
    }
  }
}
