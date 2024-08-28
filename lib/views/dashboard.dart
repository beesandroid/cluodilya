import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DashBoardDetails'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "StudentId": 2548,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        dashboardData = json.decode(response.body);
      });
    } else {
      // Handle errors
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Dashboard', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: dashboardData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dashboardData!['detailsOfHostelList'] != null) ...[
                Text('Hostel Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    )),
                buildHostelDetails(dashboardData!['detailsOfHostelList']),
              ],
              if (dashboardData!['detailsOfTransportList'] != null) ...[
                SizedBox(height: 20),
                Text('Transport Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    )),
                buildTransportDetails(dashboardData!['detailsOfTransportList']),
              ],
              if (dashboardData!['displayOfFeesList'] != null) ...[
                SizedBox(height: 20),
                Text('Fees Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    )),
                buildFeesDetails(dashboardData!['displayOfFeesList']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHostelDetails(List<dynamic> hostelList) {
    return Column(
      children: hostelList.map((hostel) {
        return Card(
          color: Colors.blueGrey[800],
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(hostel['hostelName'],
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            subtitle: Text('${hostel['roomTypeName']} - Room No: ${hostel['roomNo']}',
                style: TextStyle(color: Colors.white70)),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTransportDetails(List<dynamic> transportList) {
    final transport = transportList[0]; // Simplified for the example

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Transport details can be displayed here',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildFeesDetails(List<dynamic> feesList) {
    final totalFees = feesList.fold<double>(
      0.0,
          (previousValue, fee) => previousValue + (fee['dueAmount'] ?? 0.0),
    );

    return Column(
      children: [
        Card(
          color: Colors.blueGrey[800],
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text('Total Fees',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            subtitle: Text('\$${totalFees.toStringAsFixed(2)}',
                 style: TextStyle(color: Colors.white70)),
          ),
        ),
      ],
    );
  }
}
