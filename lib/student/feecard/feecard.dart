import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

class FeeCard extends StatefulWidget {
  const FeeCard({super.key});

  @override
  State<FeeCard> createState() => _FeeCardState();
}

class _FeeCardState extends State<FeeCard> {
  Map<String, dynamic>? feeCardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeCardData();
  }

  Future<void> _fetchFeeCardData() async {
    final url = Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeeCardDisplay');
    final body = {
      "GrpCode": "Bees",
      "ColCode": "0001",
      "CollegeId": "1",
      "HallTicketNo": "Y23AE1202",
      "AcYear": "2024 - 2025"
    };

    try {
      final response = await http.post(url, body: json.encode(body), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          feeCardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: const Text('Fee Card',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feeCardData != null
          ? _buildFeeCardContent()
          : const Center(child: Text('Failed to load fee card data')),
    );
  }

  Widget _buildFeeCardContent() {
    List feeCardList = feeCardData!['feeCardList'];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: feeCardList.length,
      itemBuilder: (context, index) {
        final feeItem = feeCardList[index];
        return _buildFeeCard(feeItem);
      },
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> feeItem) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(color: Colors.blue,

          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(5, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Fee Name", feeItem['feeName'], Icons.currency_rupee),
            _buildInfoRow("Academic Year", feeItem['acYear'], Icons.calendar_today),

            _buildInfoRow("Total Amount", "₹${feeItem['totalAmount'].toStringAsFixed(2)}", Icons.account_balance_wallet),
            _buildInfoRow("Due Amount", "₹${feeItem['dueAmount'].toStringAsFixed(2)}", Icons.warning),


          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
