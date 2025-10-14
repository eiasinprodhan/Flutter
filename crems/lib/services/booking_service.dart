import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  static const String baseUrl = 'http://localhost:8080/api/bookings';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Booking>> getAllBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all bookings error: $e');
      rethrow;
    }
  }

  static Future<bool> createBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(booking.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Create booking error: $e');
      return false;
    }
  }

  static Future<bool> updateBooking(Booking booking) async {
    if (booking.id == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(booking.toJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Update booking error: $e');
      return false;
    }
  }

  static Future<bool> deleteBooking(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete booking error: $e');
      return false;
    }
  }
}