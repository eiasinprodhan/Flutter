class Attendance {
  int? id;
  int? employeeId;
  int? stageId;
  String? date;
  String? status;
  int? salary;

  Attendance({this.id, this.employeeId, this.stageId, this.date, this.status, this.salary});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employeeId'],
      stageId: json['stageId'],
      date: json['date'],
      status: json['status'],
      salary: json['salary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'stageId': stageId,
      'date': date,
      'status': status,
      'salary': salary,
    };
  }
}