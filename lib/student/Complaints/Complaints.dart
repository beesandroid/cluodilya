import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class ComplaintsDropdownMenus extends StatefulWidget {
  const ComplaintsDropdownMenus({Key? key}) : super(key: key);

  @override
  _ComplaintsDropdownMenusState createState() => _ComplaintsDropdownMenusState();
}

class _ComplaintsDropdownMenusState extends State<ComplaintsDropdownMenus> {
  String selectedMainTab = 'Timetable';
  String selectedSubTab = 'Internal';
  String selectedIssueType = 'Defect';
  String selectedSeverity = 'Critical';
  final TextEditingController _textController = TextEditingController();

  late String? betStudId;
  bool _isLoading = false;

  final List<String> mainTabs = [
    'Timetable',
    'Fee Payments',
    'Downloads',
    'Marks Details',
    'Basic Information',
  ];

  final Map<String, List<String>> subTabs = {
    'Timetable': ['Internal', 'External'],
    'Fee Payments': [
      'Regular',
      'Supplementary',
      'Re-evaluation',
      'Fee Information'
    ],
    'Downloads': ['None'],
    'Marks Details': [
      'Mid Marks',
      'Final Internal Marks',
      'Overall Performance'
    ],
    'Basic Information': ['None'],
  };

  final List<String> issueTypes = ['Defect', 'Enhancement'];
  final List<String> severities = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Report Issues',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDropdownMenu(mainTabs, selectedMainTab, (String? value) {
                if (value != null) {
                  setState(() {
                    selectedMainTab = value;
                    selectedSubTab = subTabs[value]!.first;
                  });
                }
              }),
              const SizedBox(height: 20),
              buildDropdownMenu(subTabs[selectedMainTab]!, selectedSubTab,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedSubTab = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              buildDropdownMenu(issueTypes, selectedIssueType,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedIssueType = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              buildDropdownMenu(severities, selectedSeverity,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedSeverity = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: 220,
                  child: TextFormField(
                    controller: _textController,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22.0),
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.blue),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdownMenu(
      List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),

            ),
          ),
        ),
        )],
    );
  }



}
