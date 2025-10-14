import 'building.dart';
import 'customer.dart';
import 'floor.dart';
import 'unit.dart';

class Booking {
  final int? id;
  final DateTime? date;
  final bool isLoan;
  final double? downPayment;
  final double? interestRate;
  final int? year;
  final double? amount;
  final double? discount;
  final double? dueAmount;
  final double? emiAmount;
  final Building? building;
  final Floor? floor;
  final Unit? unit;
  final Customer? customer;

  Booking({
    this.id,
    this.date,
    required this.isLoan,
    this.downPayment,
    this.interestRate,
    this.year,
    this.amount,
    this.discount,
    this.dueAmount,
    this.emiAmount,
    this.building,
    this.floor,
    this.unit,
    this.customer,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isLoan: json['isLoan'] ?? false,
      downPayment: (json['downPayment'] as num?)?.toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      year: json['year'],
      amount: (json['amount'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      dueAmount: (json['dueAmount'] as num?)?.toDouble(),
      emiAmount: (json['emiAmount'] as num?)?.toDouble(),
      building: json['building'] != null ? Building.fromJson(json['building']) : null,
      floor: json['floor'] != null ? Floor.fromJson(json['floor']) : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'isLoan': isLoan,
      'downPayment': downPayment,
      'interestRate': interestRate,
      'year': year,
      'amount': amount,
      'discount': discount,
      'dueAmount': dueAmount,
      'emiAmount': emiAmount,
      // For saving, we only need to send the ID of the related entities
      'building': building != null ? {'id': building!.id} : null,
      'floor': floor != null ? {'id': floor!.id} : null,
      'unit': unit != null ? {'id': unit!.id} : null,
      'customer': customer != null ? {'id': customer!.id} : null,
    };
  }
}