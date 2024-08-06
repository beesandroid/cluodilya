import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutController extends GetxController {
  Future<void> logout() async {
    try {
      // Clear all stored preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();  // This clears all keys and values in SharedPreferences

      // Optionally, you can also remove specific keys if you prefer
      // await prefs.remove('key');

      // Navigate back to the login screen
      Get.offNamed('/login');  // Redirect to the login screen
    } catch (e) {
      // Handle any errors that may occur
      Get.snackbar('Error', 'An error occurred while logging out: ${e.toString()}');
    }
  }
}
