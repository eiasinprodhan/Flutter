class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? photo;
  String? role;
  bool? active;
  bool? isLock;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.photo,
    this.role,
    this.active,
    this.isLock,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      photo: json['photo'],
      role: json['role'],
      active: json['active'],
      isLock: json['isLock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'photo': photo,
      'role': role,
      'active': active,
      'isLock': isLock,
    };
  }
}