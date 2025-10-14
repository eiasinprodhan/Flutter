// lib/services/raw_material_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/raw_material.dart';
import 'auth_service.dart'; // Assuming you have a similar auth service

class RawMaterialService {
  static const String baseUrl = 'http://localhost:8080/api/rawmaterials';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<RawMaterial>> getAllRawMaterials() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RawMaterial.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load raw materials: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all raw materials error: $e');
      rethrow;
    }
  }

  static Future<bool> createRawMaterial(RawMaterial material) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(material.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Create raw material error: $e');
      return false;
    }
  }

  static Future<bool> updateRawMaterial(RawMaterial material) async {
    if (material.id == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(material.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update raw material error: $e');
      return false;
    }
  }

  static Future<bool> deleteRawMaterial(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
      // The Spring controller returns 204 No Content on success
      return response.statusCode == 204;
    } catch (e) {
      print('Delete raw material error: $e');
      return false;
    }
  }
}