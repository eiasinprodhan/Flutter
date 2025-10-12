import 'user.dart';

class Employee {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  int? nid;
  DateTime? joiningDate;
  String? role;
  String? salaryType;
  double? salary;
  bool? status;
  String? photo;
  String? country;
  String? address;
  double? totalSalary;
  DateTime? lastSalary;
  User? user;

  Employee({
    this.id,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.nid,
    this.joiningDate,
    this.role,
    this.salaryType,
    this.salary,
    this.status,
    this.photo,
    this.country,
    this.address,
    this.totalSalary,
    this.lastSalary,
    this.user,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      nid: json['nid'],
      joiningDate: json['joiningDate'] != null
          ? DateTime.parse(json['joiningDate'])
          : null,
      role: json['role'],
      salaryType: json['salaryType'],
      salary: json['salary']?.toDouble(),
      status: json['status'],
      photo: json['photo'],
      country: json['country'],
      address: json['address'],
      totalSalary: json['totalSalary']?.toDouble(),
      lastSalary: json['lastSalary'] != null
          ? DateTime.parse(json['lastSalary'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'nid': nid,
      'joiningDate': joiningDate?.toIso8601String(),
      'role': role,
      'salaryType': salaryType,
      'salary': salary,
      'status': status,
      'photo': photo,
      'country': country,
      'address': address,
      'totalSalary': totalSalary,
      'lastSalary': lastSalary?.toIso8601String(),
    };
  }
}