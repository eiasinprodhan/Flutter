import 'dart:convert';

import 'package:crems/entity/Project.dart';
import 'package:crems/services/AuthService.dart';
import 'package:http/http.dart' as http;

class ProjectService{
  final String baseUrl = "http://localhost:8080/api/projects";

  Future<List<Project>> getAllProjects() async{
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.get(
        url,
      headers: headers
    );

    if(response.statusCode == 200){
      List<dynamic> projects = jsonDecode(response.body);
      return projects.map((json) => Project.fromJson(json)).toList();
    }else{
      throw Exception('Failed to load projecs.');
    }
  }

  Future<Project> getProjectById() async{
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.get(
        url,
      headers: headers
    );

    if(response.statusCode == 200){
      final project = jsonDecode(response.body);
      return Project.fromJson(project);
    }else{
      throw Exception('Failed to load project.');
    }
  }

  Future<bool> saveProject(Project project) async{
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(project.toJson())
    );

    if(response == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> updateProject(Project project) async{
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(project.toJson())
    );

    if(response == 200){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteProject(int id) async{
    String? token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/$id');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
        url,
        headers: headers
    );

    if(response == 200){
      return true;
    }else{
      return false;
    }
  }
}