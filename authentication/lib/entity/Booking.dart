import 'package:crems/entity/Building.dart';
import 'package:crems/entity/Customer.dart';
import 'package:crems/entity/Floor.dart';
import 'package:crems/entity/Unit.dart';

class Booking {
  int? id;
  String? date;
  int? downPayment;
  int? interestRate;
  int? year;
  int? amount;
  int? discount;
  int? dueAmount;
  int? emiAmount;
  Building? building;
  Floor? floor;
  Unit? unit;
  Customer? customer;
  bool? loan;
  bool? isLoan;

  Booking({this.id, this.date, this.downPayment, this.interestRate, this.year, this.amount, this.discount, this.dueAmount, this.emiAmount, this.building, this.floor, this.unit, this.customer, this.loan, this.isLoan});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      date: json['date'],
      downPayment: json['downPayment'],
      interestRate: json['interestRate'],
      year: json['year'],
      amount: json['amount'],
      discount: json['discount'],
      dueAmount: json['dueAmount'],
      emiAmount: json['emiAmount'],
      building: json['building'] != null ? Building.fromJson(json['building']) : null,
      floor: json['floor'] != null ? Floor.fromJson(json['floor']) : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      loan: json['loan'],
      isLoan: json['isLoan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'downPayment': downPayment,
      'interestRate': interestRate,
      'year': year,
      'amount': amount,
      'discount': discount,
      'dueAmount': dueAmount,
      'emiAmount': emiAmount,
      'building': building?.toJson(),
      'floor': floor?.toJson(),
      'unit': unit?.toJson(),
      'customer': customer?.toJson(),
      'loan': loan,
      'isLoan': isLoan,
    };
  }
}