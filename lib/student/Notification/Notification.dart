import 'package:flutter/material.dart';

class Noti extends StatefulWidget {
  const Noti({super.key});

  @override
  State<Noti> createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        backgroundColor: Colors.white, // Customize the background color if needed
      ),
      body: Center(
        child: Text(
          'No Notifications Available', // Customize the text as needed
          style: TextStyle(
            fontSize: 20,
            color: Colors.black, // Customize the text color if needed
          ),
        ),
      ),
    );
  }
}
