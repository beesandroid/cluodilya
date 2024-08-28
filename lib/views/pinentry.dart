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
        backgroundColor: Colors.white,

        title: Text('Enter PIN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // Ensure the Column takes minimum vertical space
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
              onCompleted: (value) {
                print('PIN Completed: $value'); // Debugging line to check if PIN is completed
                _verifyPin(value);
              },
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
                  print('Button Pressed with PIN: $_currentText'); // Debugging line
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
    print('Entered PIN for verification: $pin'); // Debugging line to confirm method call

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString('pin');
      final userType = prefs.getString('userType');

      print('Stored PIN: $storedPin'); // Debugging line
      print('User Type: $userType'); // Debugging line

      if (storedPin == null) {
        print('Stored PIN is null'); // Debugging line
        Get.snackbar('Error', 'Stored PIN not found.');
        return;
      }

      if (pin.isNotEmpty && pin == storedPin) {
        if (userType == 'EMPLOYEE') {
          print('Navigating to Employee Dashboard'); // Debugging line
          Get.offNamed('/Empdashboard');
        } else if (userType == 'STUDENT') {
          print('Navigating to Student Dashboard'); // Debugging line
          Get.offNamed('/StudentDashboard');
        } else {
          print('Invalid user type: $userType'); // Debugging line
          Get.snackbar('Error', 'Invalid user type.');
        }
      } else {
        print('Invalid PIN entered: $pin'); // Debugging line
        Get.snackbar('Error', 'Invalid PIN.');
      }
    } catch (e) {
      print('Error: ${e.toString()}'); // Debugging line
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    }
  }

}