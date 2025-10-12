import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');

      final response = await ApiService.post(
        '${AppConstants.authEndpoint}/login',
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));

        if (authResponse.token != null) {
          await ApiService.saveToken(authResponse.token!);
          print('✅ Login successful - Token saved');
        }

        return authResponse;
      } else {
        print('❌ Login failed: ${response.statusCode}');
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('💥 Login error: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 Logging out...');

      await ApiService.post('${AppConstants.authEndpoint}/logout', {});
      await ApiService.removeToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);

      print('✅ Logout successful');
    } catch (e) {
      print('⚠️ Logout error: $e');
      await ApiService.removeToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final hasToken = await ApiService.hasToken();
    print('🔍 Login status: ${hasToken ? "Logged In" : "Not Logged In"}');
    return hasToken;
  }

  Future<void> saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
      print('✅ User data saved');
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  Future<User?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userKey);

      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }

      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }
}