class Customer {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? photo;

  Customer({this.id, this.name, this.email, this.phone, this.address, this.photo});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo': photo,
    };
  }
}