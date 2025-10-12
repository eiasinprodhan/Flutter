class AuthResponse {
  String? token;
  String? message;

  AuthResponse({this.token, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'message': message,
    };
  }
}