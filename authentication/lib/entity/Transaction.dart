class Transaction {
  int? id;
  String? name;
  String? date;
  int? amount;
  bool? credit;

  Transaction({this.id, this.name, this.date, this.amount, this.credit});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      amount: json['amount'],
      credit: json['credit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'amount': amount,
      'credit': credit,
    };
  }
}