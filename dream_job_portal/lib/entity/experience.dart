

class Experience {
  final int id;
  final String company;
  final String position;
  final String? fromDate;
  final String? toDate;
  final String? description;

  Experience({
    required this.id,
    required this.company,
    required this.position,
    this.fromDate,
    this.toDate,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      description: json['description'],
    );
  }
}

