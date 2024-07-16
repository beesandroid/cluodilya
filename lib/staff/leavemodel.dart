class LeaveData {
  final String absenceName;
  final String accrualPeriodName;
  final double balance;
  final String lastAccruedDate;
  final double accrued;

  LeaveData({
    required this.absenceName,
    required this.accrualPeriodName,
    required this.balance,
    required this.lastAccruedDate,
    required this.accrued,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      absenceName: json['absenceName'] ?? '',
      accrualPeriodName: json['accrualPeriodName'] ?? '',
      balance: json['balance']?.toDouble() ?? 0.0,
      lastAccruedDate: json['lastAccruedDate'] ?? '',
      accrued: json['accrued']?.toDouble() ?? 0.0,
    );
  }
}
