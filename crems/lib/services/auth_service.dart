import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/auth';
  static String? _token;

  static String? get token => _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        _token = authResponse.token;
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<bool> logout() async {
    try {
      if (_token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        _token = null;
        return true;
      }
      return false;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  static Future<bool> activeUser(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/active/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Active user error: $e');
      return false;
    }
  }

  static bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }
}