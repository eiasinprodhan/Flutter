import 'user_model.dart';

class Employee {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String phone;
  final int nid;
  final DateTime? joiningDate;
  final String role;
  final String salaryType;
  final double salary;
  final bool status;
  final String? photo;
  final String country;
  final String address;
  final double? totalSalary;
  final DateTime? lastSalary;
  final User? user;

  Employee({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.phone,
    required this.nid,
    this.joiningDate,
    required this.role,
    required this.salaryType,
    required this.salary,
    this.status = true,
    this.photo,
    required this.country,
    required this.address,
    this.totalSalary,
    this.lastSalary,
    this.user,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'] ?? '',
      nid: json['nid'] is int ? json['nid'] : int.tryParse(json['nid'].toString()) ?? 0,
      joiningDate: json['joiningDate'] != null
          ? DateTime.parse(json['joiningDate'])
          : null,
      role: json['role'] ?? '',
      salaryType: json['salaryType'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      status: json['status'] ?? true,
      photo: json['photo'],
      country: json['country'] ?? '',
      address: json['address'] ?? '',
      totalSalary: json['totalSalary']?.toDouble(),
      lastSalary: json['lastSalary'] != null
          ? DateTime.parse(json['lastSalary'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      'phone': phone,
      'nid': nid,
      if (joiningDate != null) 'joiningDate': joiningDate!.toIso8601String(),
      'role': role,
      'salaryType': salaryType,
      'salary': salary,
      'status': status,
      if (photo != null) 'photo': photo,
      'country': country,
      'address': address,
      if (totalSalary != null) 'totalSalary': totalSalary,
      if (lastSalary != null) 'lastSalary': lastSalary!.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}