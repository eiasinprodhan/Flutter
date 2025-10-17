class StagePayment {
  int? id;
  String? name;
  int? quantity;
  String? unit;

  StagePayment({this.id, this.name, this.quantity, this.unit});

  factory StagePayment.fromJson(Map<String, dynamic> json) {
    return StagePayment(
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