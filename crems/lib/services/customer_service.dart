import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/customer.dart';
import 'auth_service.dart';

class CustomerService {
  static const String baseUrl = 'http://localhost:8080/api/customers';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all customers error: $e');
      rethrow;
    }
  }

  static Future<bool> createCustomer(Customer customer, XFile? photo) async {
    try {
      // NOTE: Assumes your backend endpoint is updated to handle multipart
      // e.g., @PostMapping(value = "/", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
      // public Customer save(@RequestPart("customer") String customerJson, @RequestPart(value = "photo", required = false) MultipartFile photo)
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/'));
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      request.fields['customer'] = jsonEncode(customer.toJson());

      if (photo != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('photo', await photo.readAsBytes(), filename: photo.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
        }
      }

      var response = await request.send();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Create customer error: $e');
      return false;
    }
  }

  static Future<bool> updateCustomer(Customer customer, XFile? photo) async {
    if (customer.id == null) return false;
    try {
      // NOTE: Assumes your backend endpoint is updated to handle multipart for PUT as well
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/'));
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      request.fields['customer'] = jsonEncode(customer.toJson());

      if (photo != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes('photo', await photo.readAsBytes(), filename: photo.name));
        } else {
          request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
        }
      }

      var response = await request.send();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Update customer error: $e');
      return false;
    }
  }

  static Future<bool> deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete customer error: $e');
      return false;
    }
  }
}