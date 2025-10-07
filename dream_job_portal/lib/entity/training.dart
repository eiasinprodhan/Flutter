class Training {
  final int id;
  final String title;
  final String institute;
  final String duration;
  final String description;

  Training({
    required this.id,
    required this.title,
    required this.institute,
    required this.duration,
    required this.description,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      title: json['title'] ?? '',
      institute: json['institute'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
