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

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString('authToken', token);
      await preferences.setString('userRole', role);

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
}