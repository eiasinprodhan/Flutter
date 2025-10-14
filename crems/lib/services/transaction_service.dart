// lib/services/transaction_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'auth_service.dart'; // Assuming you have a similar auth service

class TransactionService {
  static const String baseUrl = 'http://localhost:8080/api/transactions';

  static Map<String, String> _getHeaders() {
    final token = AuthService.token;
    if (token == null || token.isEmpty) throw Exception('Auth token not found.');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'), headers: _getHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all transactions error: $e');
      rethrow;
    }
  }

  static Future<bool> createTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(transaction.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Create transaction error: $e');
      return false;
    }
  }

  static Future<bool> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/'),
        headers: _getHeaders(),
        body: jsonEncode(transaction.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update transaction error: $e');
      return false;
    }
  }

  static Future<bool> deleteTransaction(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getHeaders());
      // Spring controller returns 204 No Content on success
      return response.statusCode == 204;
    } catch (e) {
      print('Delete transaction error: $e');
      return false;
    }
  }
}