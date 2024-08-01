import 'package:flutter/material.dart';

class OutingRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Outing Request Content',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
