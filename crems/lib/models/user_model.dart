class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? password;
  final String? photo;
  final String role;
  final bool active;
  final bool isLock;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    this.photo,
    required this.role,
    this.active = false,
    this.isLock = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: json['password'],
      photo: json['photo'],
      role: json['role'] ?? 'USER',
      active: json['active'] ?? false,
      isLock: json['isLock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (password != null) 'password': password,
      if (photo != null) 'photo': photo,
      'role': role,
      'active': active,
      'isLock': isLock,
    };
  }
}