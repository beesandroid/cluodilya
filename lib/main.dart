import 'dart:convert';

import 'package:cloudilya/student/Hostal.dart';
import 'package:cloudilya/student/StudentDashboard.dart';
import 'package:cloudilya/student/feepayment.dart';
import 'package:cloudilya/student/hostal/hostalManagement.dart';
import 'package:cloudilya/views/pin%20verification.dart';
import 'package:cloudilya/views/pinScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'staff/Attendence.dart';
import 'staff/EmpDashboard.dart';
import 'staff/LeaveApplication.dart';
import 'views/Signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? storedPin = prefs.getString('pin');

  print('Stored PIN: $storedPin'); // Debugging line

  runApp(MyApp(isLoggedIn: isLoggedIn, storedPin: storedPin));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? storedPin;

  MyApp({required this.isLoggedIn, this.storedPin});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: determineInitialRoute(),
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen(isLoggedIn: isLoggedIn)),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/Empdashboard', page: () => EmpDashboard()),
        GetPage(name: '/signup', page: () => NewSignupScreen()),
        GetPage(name: '/attendance_screen', page: () => AttendanceScreen()),
        GetPage(name: '/LeaveApplication', page: () => LeaveApplicationScreen()),
        GetPage(name: '/FeePaymentScreen', page: () => FeePaymentScreen()),
        GetPage(name: '/StudentDashboard', page: () => StudentDashboard()),
        GetPage(name: '/HostelSelector', page: () => HostelSelector()),
        GetPage(name: '/HostelManagement', page: () => HostelManagement()),
        GetPage(name: '/pin_setup', page: () => PinSetupScreen()),
        GetPage(name: '/pin_verification', page: () => PinVerificationScreen()),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Text',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String determineInitialRoute() {
    if (storedPin != null && storedPin!.isNotEmpty) {
      if (isLoggedIn) {
        return '/pin_verification';
      } else {
        return '/login';
      }
    } else {
      return '/login';
    }
  }
}

class SplashScreen extends StatelessWidget {
  final bool isLoggedIn;

  SplashScreen({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('userType');

      if (isLoggedIn) {
        if (userType == 'STUDENT') {
          Get.offNamed('/StudentDashboard');
        } else if (userType == 'EMPLOYEE') {
          Get.offNamed('/EmpDashboard');
        } else {
          Get.offNamed('/login');
        }
      } else {
        Get.offNamed('/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/image.png', width: 150, height: 150),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image.png', width: 150, height: 150),
              SizedBox(height: 20.0),
              _buildTextField('UserID', controller: _loginController.userIdController),
              SizedBox(height: 20.0),
              _buildTextField('Password', obscureText: true, controller: _loginController.passwordController),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () {
                  _loginController.login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003d85),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return Checkbox(
                      value: _loginController.rememberMe.value,
                      onChanged: (bool? value) {
                        _loginController.rememberMe.value = value ?? false;
                      },
                      activeColor: Colors.white,
                      checkColor: Color(0xFF003d85),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }),
                  Text(
                    'Remember me',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/signup');
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF003d85),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Powered by Bees Software Solutions PVT.LTD',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField(String hintText, {bool obscureText = false, required TextEditingController controller}) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
      style: TextStyle(color: Colors.grey), // Grey input text
    );
  }
}
class LoginController extends GetxController {
  var userIdController = TextEditingController();
  var passwordController = TextEditingController();
  var rememberMe = false.obs;

  final Dio _dio = Dio();
  final String _loginUrl = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/GetLoginUserDetails';

  void login() async {
    final userName = userIdController.text.trim();
    final password = passwordController.text.trim();

    if (userName.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in both fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await _dio.post(
        _loginUrl,
        data: {
          'GrpCode': '',
          'UserName': userName,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to parse response data: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }

        if (responseData is Map<String, dynamic>) {
          handleLoginResponse(responseData);
        } else {
          Get.snackbar(
            'Error',
            'Unexpected response format.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Login failed with status code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void handleLoginResponse(Map<String, dynamic> responseData) async {
    if (responseData.containsKey('loginUesrDetailsList') &&
        responseData.containsKey('message')) {
      final loginUserDetailsList = responseData['loginUesrDetailsList'];
      final message = responseData['message'];

      if (message == 'Login Successfully' &&
          loginUserDetailsList != null &&
          loginUserDetailsList.isNotEmpty) {
        final singleLoginUserDetails = loginUserDetailsList[0];
        final status = singleLoginUserDetails['status'] as int?;
        final userType = singleLoginUserDetails['userType'] as String?;

        await saveResponseToSharedPreferences(singleLoginUserDetails);

        final prefs = await SharedPreferences.getInstance();
        final pin = prefs.getString('pin');

        if (pin == null || pin.isEmpty) {
          Get.offNamed('/pin_setup');
        } else {
          if (status != null) {
            if (userType == 'STUDENT' && status == 0) {
              Get.offNamed('/StudentDashboard');
            } else if (userType == 'EMPLOYEE' && status == 1) {
              Get.offNamed('/Empdashboard');
            } else {
              Get.snackbar(
                'Error',
                'Unexpected status value or user type.',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            Get.snackbar(
              'Error',
              'Status value is null.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Invalid credentials. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Unexpected response format.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

Future<void> saveResponseToSharedPreferences(Map<String, dynamic> responseBody) async {
  final prefs = await SharedPreferences.getInstance();

  responseBody.forEach((key, value) {
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else {
      prefs.setString(key, value.toString());
    }
  });
  await prefs.setBool('isLoggedIn', true);
}
