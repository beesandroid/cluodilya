import 'dart:convert';
import 'dart:ui'; // For blur effect
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeeCard extends StatefulWidget {
  const FeeCard({super.key});

  @override
  State<FeeCard> createState() => _FeeCardState();
}

class _FeeCardState extends State<FeeCard> {
  Map<String, dynamic>? feeCardData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFeeCardData();
  }

  Future<void> _fetchFeeCardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCode = prefs.getString('grpCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String studId = prefs.getString('studId') ?? '';
    String acYear = prefs.getString('acYear') ?? '';

    final url = Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FeeCardDisplay');
    final body = {
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "HallTicketNo":userName,
      "AcYear":acYear
    };
    print(body);

    try {
      final response = await http.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          feeCardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred while fetching data.';
      });
      print('Error occurred: $e');
    }
  }

  /// Builds the fee details card with glassmorphism effect
  Widget _buildFeeCard(Map<String, dynamic> feeItem) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          // Glassmorphism effect
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Fee Name", feeItem['feeName'], Icons.currency_rupee),
                  const SizedBox(height: 12),
                  _buildInfoRow("Academic Year", feeItem['acYear'], Icons.calendar_today),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Total Amount",
                    feeItem['totalAmount'] != null
                        ? "₹${double.parse(feeItem['totalAmount'].toString()).toStringAsFixed(2)}"
                        : "₹0.00",
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    "Due Amount",
                    feeItem['dueAmount'] != null
                        ? "₹${double.parse(feeItem['dueAmount'].toString()).toStringAsFixed(2)}"
                        : "₹0.00",
                    Icons.warning,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single information row with an icon, label, and value
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
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
    );
  }

  /// Builds the main content based on the current state
  Widget _buildContent() {
    if (isLoading) {
      // Show loading indicator while fetching data
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      // Show error message
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (feeCardData != null &&
        feeCardData!['feeCardList'] != null &&
        feeCardData!['feeCardList'].isNotEmpty) {
      // Show fee card details
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: feeCardData!['feeCardList'].length,
        itemBuilder: (context, index) {
          final feeItem = feeCardData!['feeCardList'][index];
          return _buildFeeCard(feeItem);
        },
      );
    } else {
      // Show no data available message
      return const Center(
        child: Text(
          'No fee card data available.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to place a background gradient and content over it
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Fee Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded content based on state
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
