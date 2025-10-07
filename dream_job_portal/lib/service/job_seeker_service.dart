import 'package:code/service/authservice.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:code/entity/jobSeeker.dart';


class JobSeekerService{

  final String baseUrl = "http://localhost:8085";


  Future<Map<String, dynamic>?> getJobSeekerProfile() async {
    String? token = await AuthService().getToken();

    if (token == null) {
      print('No token found, please login first.');
      return null;
    }

    final url = Uri.parse('$baseUrl/api/jobseeker/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load profile: ${response.statusCode} - ${response.body}');
      return null;
    }
  }



}
