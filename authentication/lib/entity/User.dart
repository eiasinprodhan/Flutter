class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? photo;
  String? role;
  List<dynamic>? tokens;
  bool? active;
  bool? enabled;
  String? username;
  bool? credentialsNonExpired;
  bool? accountNonExpired;
  bool? lock;
  bool? accountNonLocked;

  User({this.id, this.name, this.email, this.phone, this.password, this.photo, this.role, this.tokens, this.active, this.enabled, this.username, this.credentialsNonExpired, this.accountNonExpired, this.lock, this.accountNonLocked});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      photo: json['photo'],
      role: json['role'],
      tokens: json['tokens'],
      active: json['active'],
      enabled: json['enabled'],
      username: json['username'],
      credentialsNonExpired: json['credentialsNonExpired'],
      accountNonExpired: json['accountNonExpired'],
      lock: json['lock'],
      accountNonLocked: json['accountNonLocked'],
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
      'tokens': tokens,
      'active': active,
      'enabled': enabled,
      'username': username,
      'credentialsNonExpired': credentialsNonExpired,
      'accountNonExpired': accountNonExpired,
      'lock': lock,
      'accountNonLocked': accountNonLocked,
    };
  }
}