import 'dart:convert';


import 'package:http/http.dart' as http;
import '../models/floor.dart';
import 'auth_service.dart';

class FloorService {
  static const String baseUrl = 'http://localhost:8080/api/floors';

  // Helper to get headers with Authorization token
  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetches all floors.
  static Future<List<Floor>> getAllFloors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Floor.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load floors. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Get all floors error: $e');
      rethrow;
    }
  }

  /// Fetches all floors for a specific building.
  static Future<List<Floor>> getFloorsByBuilding(int buildingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?building=$buildingId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Floor.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load floors for building. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Get floors by building error: $e');
      rethrow;
    }
  }

  /// Creates a new floor.
  static Future<bool> createFloor(Floor floor) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(floor.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Create floor error: $e');
      return false;
    }
  }

  /// Updates an existing floor.
  static Future<bool> updateFloor(Floor floor) async {
    if (floor.id == null) {
      print('Error: Floor ID is null for update.');
      return false;
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(floor.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Update floor error: $e');
      return false;
    }
  }

  /// Deletes a floor by its ID.
  static Future<bool> deleteFloor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete floor error: $e');
      return false;
    }
  }
}