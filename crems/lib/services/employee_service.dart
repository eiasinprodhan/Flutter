import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/employee.dart';
import '../models/user.dart';
import 'auth_service.dart';

class EmployeeService {
  static const String baseUrl = 'http://localhost:8080/api/employees';

  // Helper to get headers
  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper to get headers for multipart requests
  static Map<String, String> _getMultipartHeaders() {
    final token = AuthService.token;
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Employee>> getAllEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all employees error: $e');
      rethrow; // Rethrow to be caught by UI
    }
  }

  static Future<Employee?> getEmployeeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get employee by id error: $e');
      return null;
    }
  }

  static Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/email/$email'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get employee by email error: $e');
      return null;
    }
  }

  static Future<List<Employee>> getEmployeesByRole(String role) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?role=$role'),
        headers: {
          'Content-Type': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get employees by role error: $e');
      return [];
    }
  }

  static Future<bool> createEmployee(
      User user, Employee employee, XFile? photo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/'));
      request.headers.addAll(_getMultipartHeaders());

      request.fields['user'] = jsonEncode(user.toJson());
      request.fields['employee'] = jsonEncode(employee.toJson());

      if (photo != null) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            bytes,
            filename: photo.name,
          ));
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('photo', photo.path),
          );
        }
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Employee created successfully');
        return true;
      } else {
        print('Failed to create employee. Status: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Create employee error: $e');
      return false;
    }
  }

  static Future<bool> updateEmployee(Employee employee, XFile? photo) async {
    // Ensure employee has an ID for update
    if (employee.id == null) {
      print('Error: Employee ID is null, cannot update.');
      return false;
    }

    try {
      // **FIX:** The PUT request URL should be '$baseUrl/' as per your backend
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/'));
      request.headers.addAll(_getMultipartHeaders());

      request.fields['employee'] = jsonEncode(employee.toJson());

      if (photo != null) {
        if (kIsWeb) {
          final bytes = await photo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            bytes,
            filename: photo.name,
          ));
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('photo', photo.path),
          );
        }
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Employee updated successfully');
        return true;
      } else {
        print('Failed to update employee. Status: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Update employee error: $e');
      return false;
    }
  }

  static Future<bool> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );

      // Check for success status codes (200, 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Employee deleted successfully');
        return true;
      } else {
        print('Failed to delete employee. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete employee error: $e');
      return false;
    }
  }
}