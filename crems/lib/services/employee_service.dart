import 'dart:convert';
import '../models/employee_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/image_picker_helper.dart';
import 'api_service.dart';

class EmployeeService {
  /// Get all employees - Token from LocalStorage
  Future<List<Employee>> getAllEmployees() async {
    try {
      print('📋 Fetching all employees...');
      final response = await ApiService.get('${AppConstants.employeeEndpoint}/');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ Retrieved ${data.length} employees');
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        ApiService.handleError(response);
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching employees: $e');
      throw Exception('Error fetching employees: $e');
    }
  }

  /// Get employee by ID - Token from LocalStorage
  Future<Employee> getEmployeeById(int id) async {
    try {
      print('👤 Fetching employee by ID: $id');
      final response = await ApiService.get('${AppConstants.employeeEndpoint}/$id');

      if (response.statusCode == 200) {
        print('✅ Employee retrieved');
        return Employee.fromJson(json.decode(response.body));
      } else {
        ApiService.handleError(response);
        throw Exception('Failed to load employee');
      }
    } catch (e) {
      print('💥 Error fetching employee: $e');
      throw Exception('Error fetching employee: $e');
    }
  }

  /// Get employee by email - Token from LocalStorage
  Future<Employee> getEmployeeByEmail(String email) async {
    try {
      print('📧 Fetching employee by email: $email');
      final response = await ApiService.get('${AppConstants.employeeEndpoint}/email/$email');

      if (response.statusCode == 200) {
        print('✅ Employee retrieved');
        return Employee.fromJson(json.decode(response.body));
      } else {
        ApiService.handleError(response);
        throw Exception('Failed to load employee');
      }
    } catch (e) {
      print('💥 Error fetching employee: $e');
      throw Exception('Error fetching employee: $e');
    }
  }

  /// Add new employee - Token from LocalStorage
  Future<Map<String, String>> addEmployee(
      User user,
      Employee employee,
      PickedImageData? imageData,
      ) async {
    try {
      if (imageData == null) {
        throw Exception('Photo is required');
      }

      print('➕ Adding new employee: ${employee.name}');

      final response = await ApiService.multipartPostEmployee(
        '${AppConstants.employeeEndpoint}/',
        json.encode(user.toJson()),
        json.encode(employee.toJson()),
        imageData,
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Employee added successfully');
        return Map<String, String>.from(json.decode(responseBody));
      } else {
        print('❌ Failed to add employee: ${response.statusCode}');
        print('Error: $responseBody');
        throw Exception('Failed to add employee: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error adding employee: $e');
      throw Exception('Error adding employee: $e');
    }
  }

  /// Update employee - Token from LocalStorage
  Future<Employee> updateEmployee(Employee employee, PickedImageData? imageData) async {
    try {
      if (imageData == null) {
        throw Exception('Photo is required');
      }

      print('✏️ Updating employee: ${employee.name}');

      final response = await ApiService.multipartPutEmployee(
        '${AppConstants.employeeEndpoint}/',
        json.encode(employee.toJson()),
        imageData,
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Employee updated successfully');
        return Employee.fromJson(json.decode(responseBody));
      } else {
        print('❌ Failed to update employee: ${response.statusCode}');
        print('Error: $responseBody');
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error updating employee: $e');
      throw Exception('Error updating employee: $e');
    }
  }

  /// Delete employee - Token from LocalStorage
  /// FIXED VERSION with better error handling
  Future<bool> deleteEmployee(int id) async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🗑️ DELETE EMPLOYEE REQUEST');
      print('Employee ID: $id');

      final response = await ApiService.delete('${AppConstants.employeeEndpoint}/$id');

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Check for successful delete (204 No Content or 200 OK)
      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Employee deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete employee');
        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');
        ApiService.handleError(response);
        return false;
      }
    } catch (e) {
      print('💥 EXCEPTION while deleting employee: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}