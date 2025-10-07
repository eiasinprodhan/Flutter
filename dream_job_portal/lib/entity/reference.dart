class Reference {
  final int id;
  final String name;
  final String contact;
  final String relation;

  Reference({
    required this.id,
    required this.name,
    required this.contact,
    required this.relation,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      id: json['id'],
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
}