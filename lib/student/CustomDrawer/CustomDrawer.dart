import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Lms.dart';
import '../../main.dart';
import '../Academics/busmap.dart';
import '../AttendaceRequest/Rquest management.dart';
import '../Complaints/Complaints.dart';
import '../Myinfo/Address.dart';
import '../Myinfo/PersonalActivity.dart';
import '../Myinfo/Personaldetails.dart';
import '../Myinfo/ReimbursementScreen.dart';
import '../feecard/feecard.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0, bottom: 15),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/pro.jpeg'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ExpansionTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.info, color: Colors.white),
                  ),
                  title: Text(
                    'Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: <Widget>[
                    _buildDrawerItem(context, Icons.person, 'Personal Details',
                        PersonalDetails()),
                    _buildDrawerItem(context, FontAwesomeIcons.location,
                        'Address Details', AddressDetailsScreen()),
                    _buildDrawerItem(context, FontAwesomeIcons.play,
                        'Student Activity', StudentActivityScreen()),
                    _buildDrawerItem(
                        context,
                        FontAwesomeIcons.moneyBillTransfer,
                        'Reimbursement',
                        ReimbursementScreen()),
                    _buildDrawerItem(context, FontAwesomeIcons.bookBookmark,
                        'Learning Assets', Lms()),
                    _buildDrawerItem(context, FontAwesomeIcons.mapLocation,
                        'View Locations', ViewLocationsPage()),
                    _buildDrawerItem(context, FontAwesomeIcons.idCardClip,
                        'Fee Card', FeeCard()),
                  ],
                ),
                _buildDrawerItem(context, Icons.comment, 'Complaints',
                    ComplaintsDropdownMenus()),
                _buildDrawerItem(context, Icons.share, 'Share App and Review',
                    requestManagement()),
                _buildDrawerItem(
                  context,
                  Icons.logout,
                  'Logout',
                  null,
                  () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(isLoggedIn: false),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget? destination,
      [Function? onTap]) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (onTap != null) {
            onTap();
          } else if (destination != null) {
            Navigator.of(context).push(_createRoute(destination));
          }
        },
      ),
    );
  }
}
