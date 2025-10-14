import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/auth';

  // --- START: ORIGINAL STATIC PROPERTIES AND METHODS (UNCHANGED) ---
  static String? _token;

  static String? get token => _token;

  static void setToken(String? token) {
    _token = token;
  }

  // Original login method, preserved for backward compatibility
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
        setToken(authResponse.token); // Updates the static token
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Original logout method
  static Future<bool> logout() async {
    // This method could be updated to call logoutAndClearSession for consistency
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
        setToken(null); // Clear static token
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
  // --- END: ORIGINAL STATIC METHODS ---


  // --- START: NEW METHODS FOR SESSION PERSISTENCE ---

  /// New login method that decodes JWT and saves session to SharedPreferences.
  static Future<bool> loginAndSaveSession(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'email': email, 'password': password});
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String token = data['token'];

        // *** CRITICAL STEP ***
        // Update the static token for compatibility with EmployeeService
        setToken(token);

        Map<String, dynamic> payload = Jwt.parseJwt(token);
        String role = payload['role'];
        String userEmail = payload['sub'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userRole', role);
        await prefs.setString('userEmail', userEmail);

        return true;
      } else {
        print('Failed to login. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('An error occurred during login: $e');
      return false;
    }
  }

  /// Clears the static token and data from SharedPreferences.
  static Future<void> logoutAndClearSession() async {
    setToken(null); // Clear static token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
    await prefs.remove('userEmail');
  }

  /// Retrieves the stored token from SharedPreferences.
  static Future<String?> getTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  static Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<bool> isTokenExpired() async {
    String? token = await getTokenFromStorage();
    if (token != null) {
      try {
        DateTime? expiryDate = Jwt.getExpiryDate(token);
        return expiryDate != null && DateTime.now().isAfter(expiryDate);
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  /// Checks if a valid, non-expired token exists in storage.
  static Future<bool> isSessionValid() async {
    String? token = await getTokenFromStorage();
    if (token != null && !(await isTokenExpired())) {
      setToken(token); // Ensure static token is hydrated on app start
      return true;
    } else {
      await logoutAndClearSession();
      return false;
    }
  }

  static Future<bool> hasRole(List<String> roles) async {
    String? role = await getUserRole();
    return role != null && roles.contains(role);
  }

  static Future<bool> isAdmin() async => await hasRole(['ADMIN']);
  static Future<bool> isProjectManager() async => await hasRole(['PROJECT_MANAGER']);
  static Future<bool> isSiteManager() async => await hasRole(['SITE_MANAGER']);
// --- END: NEW METHODS ---
}