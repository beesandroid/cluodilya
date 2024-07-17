// Future<void> _adjustLeaveApplication() async {
//   final fromDateStr = _fromDate?.toIso8601String().split('T').first ?? '';
//   final toDateStr = _toDate?.toIso8601String().split('T').first ?? '';
//   final leaveDuration = _fromDate != null && _toDate != null
//       ? _toDate!.difference(_fromDate!).inDays
//       : 0;
//   final attachFileName = _selectedFile != null ? _selectedFile!.path.split('/').last : '';
//
//   final requestBody = {
//     "GrpCode": "bees",
//     // "CollegeId": "1",
//     "ColCode": "0001",
//     "EmployeeId": "49",
//     "ApplicationId": "0",
//     "Flag": "REVIEW",
//     "UserId": "716",
//     "AttachFile1": attachFileName,
//     "Reason1": _reason,
//     "LeaveApplicationSaveTablevariable": [
//       {
//         "AbsenceType": _selectedRowIndex ?? 0,
//         "FromDate": fromDateStr,
//         "ToDate": toDateStr,
//         "LeaveDuration": leaveDuration,
//         "Reason": _reason,
//         "AttachFile": attachFileName,
//       }
//     ]
//   };
//
//   try {
//     final response = await http.post(
//       Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/EmployeeLeaveApplication'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(requestBody),
//     );
//
//     if (response.statusCode == 200) {
//       print(response.body);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Leave application submitted successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to submit leave application')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('An error occurred: $e')),
//     );
//   }
// }
