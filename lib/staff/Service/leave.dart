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
      body: json.encode(
          {
        "GrpCode": "bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "1",
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY",
      }
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data'); // Log the entire response to inspect the structure
      return data['employeeLeavesDisplayList'] as List<dynamic>;
    } else {
      throw Exception('Failed to load leave types');
    }
  }



  Future<Map<String, dynamic>> fetchHostelData() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "AcYear": "2024 - 2025",
        "UserTypeName": "STUDENT",
        "RegistrationDate": "",
        "StudentId": "1679",
        "HostelId": "0",
        "RoomTypeId": "0",
        "RoomId": "0"
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}
