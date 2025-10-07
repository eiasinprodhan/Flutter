class Hobby {
  final int id;
  final String name;

  Hobby({required this.id, required this.name});

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
