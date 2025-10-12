import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import '../utils/constants.dart';
import '../utils/image_picker_helper.dart';

class ApiService {
  // ============================================
  // TOKEN MANAGEMENT - LocalStorage
  // ============================================

  /// Get token from LocalStorage (SharedPreferences)
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);

      if (token != null && token.isNotEmpty) {
        print('✅ Token retrieved from LocalStorage: ${token.substring(0, 30)}...');
        return token;
      } else {
        print('⚠️ No token found in LocalStorage');
        return null;
      }
    } catch (e) {
      print('❌ Error getting token from LocalStorage: $e');
      return null;
    }
  }

  /// Save token to LocalStorage
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      print('✅ Token saved to LocalStorage successfully');
      print('🔑 Token: ${token.substring(0, 30)}...');
    } catch (e) {
      print('❌ Error saving token to LocalStorage: $e');
      rethrow;
    }
  }

  /// Remove token from LocalStorage
  static Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      print('✅ Token removed from LocalStorage');
    } catch (e) {
      print('❌ Error removing token from LocalStorage: $e');
      rethrow;
    }
  }

  /// Check if token exists in LocalStorage
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // HEADERS - Always includes token from LocalStorage
  // ============================================

  /// Get headers with auth token from LocalStorage
  /// @param includeAuth - whether to include Authorization header (default: true)
  /// @returns Map of headers with token from LocalStorage
  static Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      // Always retrieve token from LocalStorage
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔑 Authorization header added from LocalStorage');
      } else {
        print('⚠️ WARNING: Auth required but no token in LocalStorage');
      }
    }

    return headers;
  }

  /// Get headers for multipart requests with auth token from LocalStorage
  static Future<Map<String, String>> getMultipartHeaders() async {
    Map<String, String> headers = {};

    // Always retrieve token from LocalStorage
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('🔑 Authorization header added to multipart request from LocalStorage');
    } else {
      print('⚠️ WARNING: No token in LocalStorage for multipart request');
    }

    return headers;
  }

  // ============================================
  // HTTP METHODS - All retrieve token from LocalStorage
  // ============================================

  /// GET request - Token retrieved from LocalStorage
  static Future<http.Response> get(String endpoint) async {
    try {
      final headers = await getHeaders(); // Gets token from LocalStorage
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 GET REQUEST');
      print('🌐 URL: $url');
      print('📋 Headers: $headers');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.get(url, headers: headers);

      print('📥 RESPONSE: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error: ${response.body}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 GET Error: $e');
      rethrow;
    }
  }

  /// POST request - Token retrieved from LocalStorage
  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body, {
        bool includeAuth = true,
      }) async {
    try {
      final headers = await getHeaders(includeAuth: includeAuth); // Gets token from LocalStorage
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 POST REQUEST');
      print('🌐 URL: $url');
      print('📋 Headers: $headers');
      print('📦 Body: ${json.encode(body)}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('📥 RESPONSE: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error: ${response.body}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 POST Error: $e');
      rethrow;
    }
  }

  /// PUT request - Token retrieved from LocalStorage
  static Future<http.Response> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final headers = await getHeaders(); // Gets token from LocalStorage
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 PUT REQUEST');
      print('🌐 URL: $url');
      print('📋 Headers: $headers');
      print('📦 Body: ${json.encode(body)}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('📥 RESPONSE: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error: ${response.body}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request - Token retrieved from LocalStorage
  static Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await getHeaders(); // Gets token from LocalStorage
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 DELETE REQUEST');
      print('🌐 URL: $url');
      print('📋 Headers: $headers');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await http.delete(url, headers: headers);

      print('📥 RESPONSE: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error: ${response.body}');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 DELETE Error: $e');
      rethrow;
    }
  }

  // ============================================
  // MULTIPART REQUESTS - Token from LocalStorage
  // ============================================

  /// Multipart POST for adding employee - Token retrieved from LocalStorage
  static Future<http.StreamedResponse> multipartPostEmployee(
      String endpoint,
      String userJson,
      String employeeJson,
      PickedImageData? imageData,
      ) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 MULTIPART POST REQUEST');
      print('🌐 URL: $url');

      var request = http.MultipartRequest('POST', url);

      // Get token from LocalStorage and add to headers
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        print('✅ Auth token added from LocalStorage');
        print('🔑 Token: ${token.substring(0, 30)}...');
      } else {
        print('⚠️ WARNING: No token in LocalStorage for multipart request!');
      }

      // Add JSON parts
      request.files.add(
        http.MultipartFile.fromString(
          'user',
          userJson,
          contentType: MediaType('application', 'json'),
        ),
      );
      print('✅ User JSON added');

      request.files.add(
        http.MultipartFile.fromString(
          'employee',
          employeeJson,
          contentType: MediaType('application', 'json'),
        ),
      );
      print('✅ Employee JSON added');

      // Add photo
      if (imageData != null) {
        if (kIsWeb && imageData.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              imageData.bytes!,
              filename: imageData.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          print('📷 Photo added (Web): ${imageData.name}');
        } else if (imageData.file != null) {
          var stream = http.ByteStream(imageData.file!.openRead());
          var length = await imageData.file!.length();

          request.files.add(
            http.MultipartFile(
              'photo',
              stream,
              length,
              filename: imageData.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          print('📷 Photo added (Mobile): ${imageData.name}');
        }
      }

      print('📋 Request Headers: ${request.headers}');
      print('📎 Files Count: ${request.files.length}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await request.send();

      print('📥 RESPONSE: ${response.statusCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 Multipart POST Error: $e');
      rethrow;
    }
  }

  /// Multipart PUT for updating employee - Token retrieved from LocalStorage
  static Future<http.StreamedResponse> multipartPutEmployee(
      String endpoint,
      String employeeJson,
      PickedImageData? imageData,
      ) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 MULTIPART PUT REQUEST');
      print('🌐 URL: $url');

      var request = http.MultipartRequest('PUT', url);

      // Get token from LocalStorage and add to headers
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        print('✅ Auth token added from LocalStorage');
        print('🔑 Token: ${token.substring(0, 30)}...');
      } else {
        print('⚠️ WARNING: No token in LocalStorage for multipart request!');
      }

      // Add employee JSON
      request.files.add(
        http.MultipartFile.fromString(
          'employee',
          employeeJson,
          contentType: MediaType('application', 'json'),
        ),
      );
      print('✅ Employee JSON added');

      // Add photo
      if (imageData != null) {
        if (kIsWeb && imageData.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              imageData.bytes!,
              filename: imageData.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          print('📷 Photo added (Web): ${imageData.name}');
        } else if (imageData.file != null) {
          var stream = http.ByteStream(imageData.file!.openRead());
          var length = await imageData.file!.length();

          request.files.add(
            http.MultipartFile(
              'photo',
              stream,
              length,
              filename: imageData.name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          print('📷 Photo added (Mobile): ${imageData.name}');
        }
      }

      print('📋 Request Headers: ${request.headers}');
      print('📎 Files Count: ${request.files.length}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final response = await request.send();

      print('📥 RESPONSE: ${response.statusCode}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return response;
    } catch (e) {
      print('💥 Multipart PUT Error: $e');
      rethrow;
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Handle HTTP errors uniformly
  static void handleError(http.Response response) {
    if (response.statusCode == 401) {
      print('🚫 Unauthorized - Token may be invalid or expired');
      removeToken(); // Remove invalid token
    } else if (response.statusCode == 403) {
      print('🚫 Forbidden - Insufficient permissions');
    } else if (response.statusCode == 404) {
      print('🚫 Not Found - Resource does not exist');
    } else if (response.statusCode >= 500) {
      print('🚫 Server Error - ${response.statusCode}');
    }
  }

  /// Parse response body safely
  static dynamic parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } catch (e) {
      print('❌ Error parsing response: $e');
      return null;
    }
  }
}