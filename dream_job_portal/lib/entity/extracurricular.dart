class Extracurricular {
  final int id;
  final String title;
  final String role;
  final String description;

  Extracurricular({
    required this.id,
    required this.title,
    required this.role,
    required this.description,
  });

  factory Extracurricular.fromJson(Map<String, dynamic> json) {
    return Extracurricular(
      id: json['id'],
      title: json['title'] ?? '',
      role: json['role'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
