import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinEntryScreen extends StatefulWidget {
  @override
  _PinEntryScreenState createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _currentText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensure the Column takes minimum vertical space
          children: [
            SizedBox(height: 100.0), // Add space at the top for centering
            PinCodeTextField(
              controller: _pinController,
              length: 4,
              obscureText: true,
              appContext: context,
              onChanged: (value) {
                setState(() {
                  _currentText = value;
                });
              },
              onCompleted: _verifyPin,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 60,
                fieldWidth: 60,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.blue.shade50,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                selectedColor: Colors.blue,
              ),
              animationType: AnimationType.fade,
              animationDuration: Duration(milliseconds: 300),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                if (_currentText.length == 4) {
                  _verifyPin(_currentText);
                } else {
                  Get.snackbar('Error', 'Please enter a 4-digit PIN.');
                }
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('pin');

    if (pin == storedPin) {
      Get.offNamed('/StudentDashboard'); // or other appropriate screen
    } else {
      Get.snackbar('Error', 'Incorrect PIN.');
    }
  }
}
