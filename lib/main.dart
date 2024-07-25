import 'package:cloudilya/student/feepayment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'staff/Attendence.dart';
import 'staff/EmpDashboard.dart';
import 'staff/LeaveApplication.dart';
import 'views/Signup.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/Empdashboard', page: () => EmpDashboard()),
        GetPage(name: '/signup', page: () => NewSignupScreen()),
        GetPage(name: '/attendance_screen', page: () => AttendanceScreen()),
        GetPage(name: '/LeaveApplication', page: () => LeaveApplicationScreen()),
        GetPage(name: '/FeePaymentScreen', page: () => FeeDetailsScreen()),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Text',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // White background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0), // Grey border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0), // Grey border on focus
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0), // Grey border when enabled
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          hintStyle: TextStyle(color: Colors.grey), // Grey hint text
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to login page after a delay
    Future.delayed(Duration(seconds: 3), () {
      Get.offNamed('Empdashboard');
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
  final String _loginUrl = 'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/GetLoginUserDetails'; // Replace with your API endpoint

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
        final responseData = response.data;

        // Check if the response contains 'singleLoginUesrDetails' and 'message'
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('singleLoginUesrDetails') &&
            responseData.containsKey('message')) {

          final singleLoginUserDetails = responseData['singleLoginUesrDetails'];
          final message = responseData['message'];

          if (message == 'Login Successfully' && singleLoginUserDetails != null) {
            // Handle successful login
            Get.offNamed('/dashboard');
          } else {
            // Handle invalid credentials or other issues
            Get.snackbar(
              'Error',
              'Invalid credentials. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          // Handle unexpected response format
          Get.snackbar(
            'Error',
            'Unexpected response format.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Handle errors based on status code
        Get.snackbar(
          'Error',
          'Login failed with status code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle exceptions
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

}