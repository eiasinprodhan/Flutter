import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/unit.dart';
import 'auth_service.dart';

class UnitService {
  static const String baseUrl = 'http://localhost:8080/api/units';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> _getMultipartHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {'Authorization': 'Bearer $token'};
  }

  static Future<List<Unit>> getAllUnits() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Unit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load units: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all units error: $e');
      rethrow;
    }
  }

  static Future<List<Unit>> getUnitsByBuildingId(int buildingId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/productdetails/$buildingId'), headers: {
        'Content-Type': 'application/json'
      });
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Unit.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get units by building error: $e');
      rethrow;
    }
  }

  static Future<bool> createUnit(Unit unit, List<XFile> photos) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/'));
      request.headers.addAll(_getMultipartHeaders());

      request.fields['unit'] = jsonEncode(unit.toJson());

      for (var photo in photos) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'photos',
            await photo.readAsBytes(),
            filename: photo.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
        }
      }

      var response = await request.send();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Create unit error: $e');
      return false;
    }
  }

  static Future<bool> updateUnit(Unit unit, List<XFile> photos) async {
    if (unit.id == null) return false;
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/'));
      request.headers.addAll(_getMultipartHeaders());

      request.fields['unit'] = jsonEncode(unit.toJson());

      for (var photo in photos) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'photos',
            await photo.readAsBytes(),
            filename: photo.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath('photos', photo.path));
        }
      }

      var response = await request.send();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Update unit error: $e');
      return false;
    }
  }

  static Future<bool> deleteUnit(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete unit error: $e');
      return false;
    }
  }
}