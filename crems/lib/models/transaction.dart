// lib/models/transaction.dart

class Transaction {
  final int? id;
  final String? name;
  final DateTime? date;
  final double? amount;
  final bool isCredit; // Renamed from 'credit' to follow Dart conventions

  Transaction({
    this.id,
    this.name,
    this.date,
    this.amount,
    this.isCredit = false, // Default to debit/expense
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      name: json['name'],
      // The date from Spring Boot is typically an ISO 8601 string
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      amount: json['amount'],
      isCredit: json['credit'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // Convert DateTime back to an ISO 8601 string for the backend
      'date': date?.toIso8601String(),
      'amount': amount,
      'credit': isCredit,
    };
  }
}