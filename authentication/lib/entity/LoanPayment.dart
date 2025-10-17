import 'package:crems/entity/Booking.dart';

class LoanPayment {
  int? id;
  double? amount;
  dynamic? date;
  Booking? booking;

  LoanPayment({this.id, this.amount, this.date, this.booking});

  factory LoanPayment.fromJson(Map<String, dynamic> json) {
    return LoanPayment(
      id: json['id'],
      amount: json['amount'],
      date: json['date'],
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'booking': booking?.toJson(),
    };
  }
}