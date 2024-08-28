import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReimbursementScreen extends StatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  _ReimbursementScreenState createState() => _ReimbursementScreenState();
}

class _ReimbursementScreenState extends State<ReimbursementScreen> {
  Map<String, dynamic>? reimbursementData;

  @override
  void initState() {
    super.initState();
    fetchReimbursementDetails();
  }

  Future<void> fetchReimbursementDetails() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/StudentReimbursementDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "Id": 0,
        "StudentId": "1400",
        "ApplicationNo": "",
        "ProceedingNumber": "",
        "ProceedingDate": "",
        "SourceName": "",
        "Year": 0,
        "UserId": 1,
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        reimbursementData = json.decode(response.body)['studentReimbursementDetailsDisplayList']?.first;
      });
    } else {
      // Handle error
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Reimbursement Details',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: reimbursementData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(

              reimbursementData!['applicationNo'],
              reimbursementData!['proceedingNumber'],
              reimbursementData!['proceedingDate'],
              reimbursementData!['sourceName'],
              reimbursementData!['year'],
              reimbursementData!['commonDate'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(

      String? applicationNo,
      String? proceedingNumber,
      String? proceedingDate,
      String? sourceName,
      int? year,
      String? commonDate,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),
            _buildDetailRow('Application No:', applicationNo),
            _buildDetailRow('Proceeding Number:', proceedingNumber),
            _buildDetailRow('Proceeding Date:', proceedingDate),
            _buildDetailRow('Source Name:', sourceName),
            _buildDetailRow('Year:', year?.toString()),
            _buildDetailRow('Common Date:', commonDate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
