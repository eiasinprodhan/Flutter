class Skill {
  final int id;
  final String name;
  final String level;

  Skill({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'] ?? '',
      level: json['level'] ?? '',
    );
  }
}
