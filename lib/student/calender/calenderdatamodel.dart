class StudentTimeTable {
  final String date;
  final String day;
  final String period1;
  final String period2;
  final String period3;
  final String period4;
  final String period5;
  final String period6;
  final String period7;
  final String period8;
  final String period9;
  final String period10;

  StudentTimeTable({
    required this.date,
    required this.day,
    required this.period1,
    required this.period2,
    required this.period3,
    required this.period4,
    required this.period5,
    required this.period6,
    required this.period7,
    required this.period8,
    required this.period9,
    required this.period10,
  });

  factory StudentTimeTable.fromJson(Map<String, dynamic> json) {
    return StudentTimeTable(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      period1: json['period1'] ?? '',
      period2: json['period2'] ?? '',
      period3: json['period3'] ?? '',
      period4: json['period4'] ?? '',
      period5: json['period5'] ?? '',
      period6: json['period6'] ?? '',
      period7: json['period7'] ?? '',
      period8: json['period8'] ?? '',
      period9: json['period9'] ?? '',
      period10: json['period10'] ?? '',
    );
  }
}
