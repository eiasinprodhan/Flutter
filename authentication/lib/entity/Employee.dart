import 'package:crems/entity/User.dart';

class Employee {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  int? nid;
  String? joiningDate;
  String? role;
  String? salaryType;
  int? salary;
  bool? status;
  String? photo;
  String? country;
  String? address;
  dynamic? totalSalary;
  dynamic? lastSalary;
  User? user;

  Employee({this.id, this.name, this.email, this.password, this.phone, this.nid, this.joiningDate, this.role, this.salaryType, this.salary, this.status, this.photo, this.country, this.address, this.totalSalary, this.lastSalary, this.user});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      nid: json['nid'],
      joiningDate: json['joiningDate'],
      role: json['role'],
      salaryType: json['salaryType'],
      salary: json['salary'],
      status: json['status'],
      photo: json['photo'],
      country: json['country'],
      address: json['address'],
      totalSalary: json['totalSalary'],
      lastSalary: json['lastSalary'],
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
      'joiningDate': joiningDate,
      'role': role,
      'salaryType': salaryType,
      'salary': salary,
      'status': status,
      'photo': photo,
      'country': country,
      'address': address,
      'totalSalary': totalSalary,
      'lastSalary': lastSalary,
      'user': user?.toJson(),
    };
  }
}