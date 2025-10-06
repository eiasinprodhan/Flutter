import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class EmployeeService {
  final String baseUrl = "http://localhost:8080/api/employees";

  /// Registers an employee with user & employee data, and optional photo.
  Future<bool> registerEmployee({
    required Map<String, dynamic> user,
    required Map<String, dynamic> employee,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/'),
      );

      // Add user and employee JSON fields
      request.fields['user'] = jsonEncode(user);
      request.fields['employee'] = jsonEncode(employee);

      // Add photo either from bytes or file
      if (photoBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'profile.png',
        ));
      } else if (photoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        ));
      }

      // Send request with timeout
      final response = await request.send().timeout(Duration(seconds: 10));

      // Check status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to register employee: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      print('Error registering employee: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getEmployeeByEmail(String email) async {
    try {
      final url = Uri.parse('$baseUrl/email/${Uri.encodeComponent(email)}');
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load employee: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting employee by email: $e');
      return null;
    }
  }
}
