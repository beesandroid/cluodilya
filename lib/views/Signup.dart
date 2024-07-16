import 'dart:convert';
import 'dart:math';
import 'package:cloudilya/views/webview_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

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
  final TextEditingController _retypePasswordController =
      TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;
  String? _serverOtp;

  // Variables to store API response values
  String? _mercid;
  String? _bdorderid;
  String? _rdata;
  String? _amount;
  String? _grpCode;
  String? _collegeId;
  String? _userName;
  String? _userType;
  String? _orderid;

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

      var url = Uri.parse('https://beessoftware.cloud/CoreAPI/CloudilyaMobileAPP/CloudAPPRegistration');
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
        print(responseBody.toString());

        // Check for the 'message' field
        String? message = responseBody['message'];
        if (message == 'User Already Registered') {
          _showToast('User already registered');
          return; // Exit the function early
        }

        // Check for "Mobile Number Not Found" message
        if (message == 'Mobile Number Not Found') {
          _showToast('Mobile Number Not Found');
          return; // Exit the function early
        }

        _serverOtp = responseBody['otp'];

        var singleCloudAPPRegistrationList = responseBody['singleCloudAPPRegistrationList'];
        var billdeskResponse = responseBody['billdeskResponse'];
        if (billdeskResponse != null) {
          String mercid = billdeskResponse['links'][1]['parameters']['mercid'];
          String bdorderid = billdeskResponse['links'][1]['parameters']['bdorderid'];
          String rdata = billdeskResponse['links'][1]['parameters']['rdata'];
          String amount = billdeskResponse['amount'];
          String grpCode = billdeskResponse['additional_info']['additional_info1'];
          String collegeId = billdeskResponse['additional_info']['additional_info3'];
          String orderid = billdeskResponse['orderid'];

          _mercid = mercid;
          _bdorderid = bdorderid;
          _rdata = rdata;
          _amount = amount;
          _grpCode = grpCode;
          _collegeId = collegeId;
          _orderid = orderid;

          print('mercid: $mercid');
          print('bdorderid: $bdorderid');
          print('rdata: $rdata');
          print('amount: $amount');
          print('grpCode: $grpCode');
          print('collegeId: $collegeId');
          print('orderid: $orderid');
        }

        if (singleCloudAPPRegistrationList != null) {
          String userName = singleCloudAPPRegistrationList['userName'];
          String userType = singleCloudAPPRegistrationList['userType'];

          print('userName: $userName');
          print('userType: $userType');

          // Store these values for later use
          _userName = userName;
          _userType = userType;
        }

        setState(() {
          _otpSent = true;
        });
        _showToast('OTP sent successfully');
      } else {
        _showToast('Failed to send OTP');
      }
    } else {
      _showToast('Error');
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

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      String orderId = _orderid.toString();
      String transactionDate =
          DateTime.now().toIso8601String().split('T').first;
      String mobile = _phoneNumberController.text;

      // Prepare request body using stored values
      var requestBody = jsonEncode({
        "GrpCode": _grpCode,
        "ColCode": "0001",
        "CollegeId": _collegeId,
        "MercId": _mercid,
        "OrderId": orderId,
        "TransactionDate": transactionDate,
        "Amount": _amount,
        "Username": _userName,
        "email": email,
        "Password": password,
        "usertype": _userType,
        "mobile": mobile
      });
      print(requestBody);

      var url = Uri.parse(
          'https://beessoftware.cloud/CoreAPI/CloudilyaMobileAPP/CloudilyaBilldeskPaymentLogs');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 204) {
        // No content to decode
        _showToast('User registered successfully');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewScreen(
                      bdorderid: _bdorderid.toString(),
                      mercid: _mercid.toString(),
                      rdata: _rdata.toString(),
                      initialUrl: '',
                    )));
      } else if (response.statusCode == 200) {
        // Successful response with content
        var responseBody = jsonDecode(response.body);
        print(responseBody);
        _showToast('User registered successfully');
      } else {
        // Handle error response
        _showToast('Failed to register user');
      }
    } else {
      _showToast('Please fix the errors before submitting.');
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
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 56.0),
                ElevatedButton(
                  onPressed: _sendOtp,
                  child:
                      Text('Send OTP', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF003d85),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 15),
          child: Text(
            "Register",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            hintText: 'Email',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ),
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 12.0),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
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
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 12.0),
        TextFormField(
          controller: _retypePasswordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            hintText: 'Retype Password',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ),
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 56.0),
        ElevatedButton(
          onPressed: _registerUser,
          child: Text('Register', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF003d85),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ],
    );
  }
}
