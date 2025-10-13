import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/building.dart';
import 'auth_service.dart';

class BuildingService {
  static const String baseUrl = 'http://localhost:8080/api/buildings';

  static Future<List<Building>> getAllBuildings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Building.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get all buildings error: $e');
      return [];
    }
  }

  static Future<Building?> getBuildingById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        return Building.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get building by id error: $e');
      return null;
    }
  }

  static Future<List<Building>> getBuildingsByProject(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?project=$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Building.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get buildings by project error: $e');
      return [];
    }
  }

  static Future<List<Building>> getBuildingsBySiteManager(int siteManagerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/siteManager?siteManager=$siteManagerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Building.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get buildings by site manager error: $e');
      return [];
    }
  }

  static Future<bool> createBuilding(Building building, XFile? photo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/'));

      request.headers['Authorization'] = 'Bearer ${AuthService.token}';

      // Add building JSON
      request.fields['building'] = jsonEncode(building.toJson());

      // Add photo if provided
      if (photo != null) {
        if (kIsWeb) {
          // For web: Read bytes
          final bytes = await photo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            bytes,
            filename: photo.name,
          ));
        } else {
          // For mobile: Use path
          request.files.add(
            await http.MultipartFile.fromPath('photo', photo.path),
          );
        }
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Building created successfully');
        return true;
      } else {
        print('Failed to create building. Status: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Create building error: $e');
      return false;
    }
  }

  static Future<bool> updateBuilding(Building building, XFile? photo) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/'));

      request.headers['Authorization'] = 'Bearer ${AuthService.token}';

      // Add building JSON
      request.fields['building'] = jsonEncode(building.toJson());

      // Add photo if provided
      if (photo != null) {
        if (kIsWeb) {
          // For web: Read bytes
          final bytes = await photo.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            bytes,
            filename: photo.name,
          ));
        } else {
          // For mobile: Use path
          request.files.add(
            await http.MultipartFile.fromPath('photo', photo.path),
          );
        }
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Building updated successfully');
        return true;
      } else {
        print('Failed to update building. Status: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Update building error: $e');
      return false;
    }
  }

  static Future<bool> deleteBuilding(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Delete building error: $e');
      return false;
    }
  }
}