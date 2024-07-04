import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../main.dart';

class NewSignupScreen extends StatefulWidget {
  const NewSignupScreen({super.key});

  @override
  State<NewSignupScreen> createState() => _NewSignupScreenState();
}

class _NewSignupScreenState extends State<NewSignupScreen> {
  final TextEditingController _groupcodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _serverOtp;

  final _formKey = GlobalKey<FormState>();

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _generateOtp() {
    var rng = Random();
    int otp = rng.nextInt(900000) + 100000; // generates a 6-digit number
    return otp.toString();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      String otp = _generateOtp();
      String grpCode = _groupcodeController.text;
      String mobile = _phoneNumberController.text;

      var url = Uri.parse(
          'https://beessoftware.cloud/CoreAPI/CloudilyaMobileAPP/CloudAPPRegistration');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'GrpCode': grpCode,
          'OTP': otp,
          'Mobile': mobile,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        _serverOtp = responseBody['otp'];
        print("Server OTP: $_serverOtp");

        if (responseBody['status']) {
          setState(() {
            _otpSent = true;
          });
          _showToast('OTP sent successfully');
        } else {
          _showToast('Failed to send OTP');
        }
      } else {
        _showToast('Error: ${response.statusCode}');
      }
    }
  }

  void _verifyOtp() {
    String enteredOtp = _otpController.text.trim();
    String? serverOtp = _serverOtp?.trim();

    if (enteredOtp == serverOtp) {
      setState(() {
        _otpVerified = true;
      });
      _showToast('OTP verified successfully');
    } else {
      _showToast('Incorrect OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Container(
        height: 800,
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _otpVerified ? _buildRegistrationForm() : _buildOtpForm(),
        ),
      ),
    );
  }

  Widget _buildOtpForm() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _otpSent
          ? Column(
              key: ValueKey(1),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 15),
                  child: Text(
                    "Enter OTP",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '', // Hide the character counter
                  ),
                ),
                SizedBox(height: 56.0),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child:
                      Text('Submit OTP', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003d85),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              key: ValueKey(0),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0, bottom: 28),
                      child: Text(
                        "Verify Your Phone Number",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _groupcodeController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    hintText: 'Group Code',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  ),
                  style: TextStyle(color: Colors.black),
                  onChanged: (text) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (value.length != 10 || int.tryParse(value) == null) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_groupcodeController.text.isEmpty ||
                        _phoneNumberController.text.isEmpty) {
                      _showToast('Please fill all fields');
                    } else {
                      _sendOtp();
                    }
                  },
                  child: Text('Get OTP', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGetOtpButtonEnabled()
                        ? Color(0xFF003d85)
                        : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      key: ValueKey(2),
      padding: EdgeInsets.all(16.0), // Add padding to the Container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 19),
            child: Text(
              "Register Your Email and Password",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              // Simple email validation
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _retypePasswordController,
            obscureText: true,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              hintText: 'Re - Type Password',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-type the password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _registerUser();
                } else {
                  _showToast('Please fix the errors before submitting.');
                }
              },
              child: Text('Register', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF003d85),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isGetOtpButtonEnabled() {
    return _groupcodeController.text.isNotEmpty &&
        _phoneNumberController.text.length == 10 &&
        int.tryParse(_phoneNumberController.text) != null;
  }

  void _registerUser() {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Perform registration logic here
    // For example, you can make an API call to register the user

    _showToast('User registered successfully with email: $email');
    // Optionally, navigate to the next screen or perform other actions
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _groupcodeController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }
}
