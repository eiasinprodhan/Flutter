import 'package:crems/entity/RawMaterial.dart';
import 'package:crems/entity/Stage.dart';

class StockOut {
  int? id;
  String? name;
  String? date;
  int? quantity;
  String? unit;
  RawMaterial? rawMaterial;
  Stage? stage;

  StockOut({this.id, this.name, this.date, this.quantity, this.unit, this.rawMaterial, this.stage});

  factory StockOut.fromJson(Map<String, dynamic> json) {
    return StockOut(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      quantity: json['quantity'],
      unit: json['unit'],
      rawMaterial: json['rawMaterial'] != null ? RawMaterial.fromJson(json['rawMaterial']) : null,
      stage: json['stage'] != null ? Stage.fromJson(json['stage']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'quantity': quantity,
      'unit': unit,
      'rawMaterial': rawMaterial?.toJson(),
      'stage': stage?.toJson(),
    };
  }
}