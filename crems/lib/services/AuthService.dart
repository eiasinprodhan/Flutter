import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  final String baseUrl = "http://localhost:8080/api/auth";
  
  Future<bool> login(String email, String password) async{
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});
    final response = await http.post(url, headers: headers, body: body);

    if(response.statusCode == 200 || response.statusCode == 201){
      final data = jsonDecode(response.body);
      String token = data['token'];

      Map<String, dynamic> payload = Jwt.parseJwt(token);
      String role = payload['role'];
      String email = payload['sub'];

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('authToken', token);
      await preferences.setString('userRole', role);
      await preferences.setString('userEmail', email);

      return true;
    }else{
      print('Failed to login.');
      return false;
    }
  }

  Future<String?> getUserRole() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? role = preferences.getString('userRole');
    print(role);
    return role;
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if (token != null) {
      DateTime expiryDate = Jwt.getExpiryDate(token)!;
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
    await prefs.remove('userEmail');
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token != null && !(await isTokenExpired())) {
      return true;
    } else {
      await logout();
      return false;
    }
  }

  Future<bool> hasRole(List<String> roles) async {
    String? role = await getUserRole();
    return role != null && roles.contains(role);
  }

  Future<bool> isAdmin() async {
    return await hasRole(['ADMIN']);
  }

  Future<bool> isProjectManager() async {
    return await hasRole(['PROJECT_MANAGER']);
  }

  Future<bool> isSiteManager() async {
    return await hasRole(['SITE_MANAGER']);
  }
}