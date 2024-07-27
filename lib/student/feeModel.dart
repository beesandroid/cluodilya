import 'dart:convert';

class FeeDetail {
  final int collegeId;
  final String colName;
  final String printName;
  final String hallTicketNo;
  final String programShortName;
  final String branchName;
  final String semester;
  final String feeName;
  final String acYear;
  final String startDate;
  final String endDate;
  final double amount;
  final double collectedAmount;
  final double dueAmount;

  FeeDetail({
    required this.collegeId,
    required this.colName,
    required this.printName,
    required this.hallTicketNo,
    required this.programShortName,
    required this.branchName,
    required this.semester,
    required this.feeName,
    required this.acYear,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.collectedAmount,
    required this.dueAmount,
  });

  factory FeeDetail.fromJson(Map<String, dynamic> json) {
    return FeeDetail(
      collegeId: json['collegeId'],
      colName: json['colName'],
      printName: json['printName'],
      hallTicketNo: json['hallTicketNo'],
      programShortName: json['programShortName'],
      branchName: json['branchName'],
      semester: json['semester'],
      feeName: json['feeName'],
      acYear: json['acYear'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      amount: json['amount'],
      collectedAmount: json['collectedAmount'],
      dueAmount: json['dueAmount'],
    );
  }
}

List<FeeDetail> parseFeeDetails(String responseBody) {
  final parsed = json.decode(responseBody)['cloudilyaStudentRegularFeeDetailsList'].cast<Map<String, dynamic>>();
  return parsed.map<FeeDetail>((json) => FeeDetail.fromJson(json)).toList();
}
