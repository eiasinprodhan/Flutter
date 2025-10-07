class Language {
  final int id;
  final String name;
  final String proficiency;

  Language({
    required this.id,
    required this.name,
    required this.proficiency,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'] ?? '',
      proficiency: json['proficiency'] ?? '',
    );
  }
}