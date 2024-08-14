import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinVerificationScreen extends StatefulWidget {
  @override
  _PinVerificationScreenState createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _currentText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(55.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 170.0),
              child: PinCodeTextField(
                controller: _pinController,
                length: 4,
                obscureText: true,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 60,
                  fieldWidth: 60,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.blue.shade50,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blue,
                ),
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                appContext: context,
                onChanged: (value) {
                  setState(() {
                    _currentText = value;
                  });
                },
                onCompleted: (value) async {
                  await _verifyPin(value);
                },
              ),
            ),
            Container(
              width: 220,
              child: ElevatedButton(
                onPressed: () async {
                  final pin = _pinController.text;
                  await _verifyPin(pin);
                },
                child:
                    Text('Verify PIN', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
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
    final userType = prefs.getString('userType');

    if (storedPin == null) {
      Get.snackbar(
        'Error',
        'No PIN stored. Please check your settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (pin == storedPin) {
      if (userType != null) {
        switch (userType) {
          case 'STUDENT':
            Get.offNamed('/StudentDashboard');
            break;
          case 'EMPLOYEE':
            Get.offNamed('/Empdashboard');
            break;
          default:
            Get.snackbar(
              'Error',
              'Unexpected user type.',
              snackPosition: SnackPosition.BOTTOM,
            );
        }
      } else {
        Get.snackbar(
          'Error',
          'User type not found.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Invalid PIN. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
