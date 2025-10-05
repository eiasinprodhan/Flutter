import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;


class EmployeeService{
  final String baseUrl = "http://localhost:8080/api/employees";

  Future<bool> registerEmployee({
    required Map<String, dynamic> user,
    required Map<String, dynamic> employee,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/'),
    );

    request.fields['user'] = jsonEncode(user);

    request.fields['employee'] = jsonEncode(employee);

    if (photoBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'profile.png'
      ));
    }

    else if (photoFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photoFile.path,
      ));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

}