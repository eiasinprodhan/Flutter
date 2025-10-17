class StockIn {
  int? id;
  String? name;
  String? date;
  int? quantity;
  String? unit;
  int? unitPrice;
  String? supplier;
  int? totalprice;

  StockIn({this.id, this.name, this.date, this.quantity, this.unit, this.unitPrice, this.supplier, this.totalprice});

  factory StockIn.fromJson(Map<String, dynamic> json) {
    return StockIn(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      quantity: json['quantity'],
      unit: json['unit'],
      unitPrice: json['unitPrice'],
      supplier: json['supplier'],
      totalprice: json['totalprice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'supplier': supplier,
      'totalprice': totalprice,
    };
  }
}