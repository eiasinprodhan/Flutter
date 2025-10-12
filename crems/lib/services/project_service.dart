import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import 'auth_service.dart';

class ProjectService {
  static const String baseUrl = 'http://localhost:8080/api/projects';

  static Future<List<Project>> getAllProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get all projects error: $e');
      return [];
    }
  }

  static Future<Project?> getProjectById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get project by id error: $e');
      return null;
    }
  }

  static Future<List<Project>> getProjectsByManager(int managerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?projectManager=$managerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get projects by manager error: $e');
      return [];
    }
  }

  static Future<bool> createProject(Project project) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(project.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Create project error: $e');
      return false;
    }
  }

  static Future<bool> updateProject(Project project) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(project.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update project error: $e');
      return false;
    }
  }

  static Future<bool> deleteProject(int id) async {
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
      print('Delete project error: $e');
      return false;
    }
  }
}