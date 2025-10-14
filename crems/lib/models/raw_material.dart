// lib/models/raw_material.dart

class RawMaterial {
  final int? id;
  final String? name;
  final int? quantity; // Java's Long maps to Dart's int
  final String? unit;

  RawMaterial({
    this.id,
    this.name,
    this.quantity,
    this.unit,
  });

  factory RawMaterial.fromJson(Map<String, dynamic> json) {
    return RawMaterial(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}