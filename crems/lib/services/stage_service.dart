import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/stage.dart';
import 'auth_service.dart';

class StageService {
  static const String baseUrl = 'http://localhost:8080/api/stages';

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

  /// Fetches all stages.
  static Future<List<Stage>> getAllStages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Stage.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load stages. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Get all stages error: $e');
      rethrow;
    }
  }

  /// Fetches all stages for a specific floor.
  static Future<List<Stage>> getStagesByFloor(int floorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?floor=$floorId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Stage.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load stages for floor. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Get stages by floor error: $e');
      rethrow;
    }
  }

  /// Creates a new stage.
  static Future<bool> createStage(Stage stage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(stage.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Create stage error: $e');
      return false;
    }
  }

  /// Updates an existing stage.
  static Future<bool> updateStage(Stage stage) async {
    if (stage.id == null) {
      print('Error: Stage ID is null for update.');
      return false;
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(stage.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Update stage error: $e');
      return false;
    }
  }

  /// Deletes a stage by its ID.
  static Future<bool> deleteStage(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete stage error: $e');
      return false;
    }
  }
}