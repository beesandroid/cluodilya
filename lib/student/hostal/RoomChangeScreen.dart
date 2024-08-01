import 'package:flutter/material.dart';

class RoomChangeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Room Change Content',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
