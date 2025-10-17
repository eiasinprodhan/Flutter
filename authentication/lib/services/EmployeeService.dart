import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crems/entity/Employee.dart';
import 'package:crems/services/AuthService.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  final String baseUrl = "http://localhost:8080/api/employees";

  Future<List<Employee>> getAllEmployee() async {
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> employees = jsonDecode(response.body);
      return employees.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees.');
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/$id');
    final headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final employee = jsonDecode(response.body);
      return Employee.fromJson(employee);
    } else {
      throw Exception('Failed to load employee.');
    }
  }

  Future<List<Employee>> getEmployeeByRole(String role) async {
    String? token = await AuthService().getToken();

    if (token == null) {
      throw Exception('Authorization token not found');
    }

    final url = Uri.parse('$baseUrl').replace(queryParameters: {'role': role});

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> employeesJson = jsonDecode(response.body);
      return employeesJson.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load employees. Status code: ${response.statusCode}',
      );
    }
  }

  Future<bool> registerEmployee({
    required Map<String, dynamic> user,
    required Map<String, dynamic> employee,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/'));

      request.fields['user'] = jsonEncode(user);
      request.fields['employee'] = jsonEncode(employee);

      if (photoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: 'profile.png',
          ),
        );
      } else if (photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoFile.path),
        );
      }

      final response = await request.send().timeout(Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Failed to register employee: ${response.statusCode} - $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Error registering employee: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getEmployeeByEmail(String email) async {
    try {
      final url = Uri.parse('$baseUrl/email/${Uri.encodeComponent(email)}');
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to load employee: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting employee by email: $e');
      return null;
    }
  }

  Future<bool> updateEmployee({
    required Employee employee,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    try {
      String? token = await AuthService().getToken();

      if (token == null) {
        print('Authorization token not found.');
        return false;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['employee'] = jsonEncode(employee);

      if (photoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoBytes,
            filename: 'profile.jpg',
          ),
        );
      } else if (photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photoFile.path,
          ),
        );
      } else {
        print('No photo provided for update.');
        return false;
      }

      final response = await request.send().timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        print('Employee not found.');
        return false;
      } else {
        final responseBody = await response.stream.bytesToString();
        print(
          'Failed to update employee: ${response.statusCode} - $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }


}
