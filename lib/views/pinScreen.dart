import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinSetupScreen extends StatefulWidget {
  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _pin = '';
  String _confirmPin = '';

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('Set PIN'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Setup a Four Digit PIN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: PinCodeTextField(
                  controller: _pinController,
                  length: 4,
                  obscureText: true,
                  appContext: context,
                  onChanged: (value) {
                    setState(() {
                      _pin = value;
                    });
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
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Re-Enter PIN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: PinCodeTextField(
                  controller: _confirmPinController,
                  length: 4,
                  obscureText: true,
                  appContext: context,
                  onChanged: (value) {
                    setState(() {
                      _confirmPin = value;
                    });
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
              ),
              SizedBox(height: 32.0),
              Container(
                width: 220,
                child: ElevatedButton(
                  onPressed: _setPin,
                  child: Text(
                    'Set PIN',
                    style: TextStyle(color: Colors.white),
                  ),
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
      ),
    );
  }

  Future<void> _setPin() async {
    if (_pin.length != 4 || _confirmPin.length != 4) {
      Get.snackbar('Error', 'PIN must be 4 digits.');
      return;
    }

    if (_pin != _confirmPin) {
      Get.snackbar('Error', 'PINs do not match.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('pin');

    if (storedPin != null) {
      Get.snackbar('Error', 'PIN is already set.');
      return;
    }

    await prefs.setString('pin', _pin);

    // Assuming you need to get user type from SharedPreferences or another source
    final userType = prefs.getString('userType') ?? 'STUDENT';

    // Navigate based on user type
    if (userType == 'EMPLOYEE') {
      Get.offNamed('/Empdashboard'); // Redirect to Employee Dashboard
    } else {
      Get.offNamed('/StudentDashboard'); // Redirect to Student Dashboard
    }
  }
}
