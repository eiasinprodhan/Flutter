// lib/models/project_model.dart
import 'employee_model.dart';

class Project {
  final int? id;
  final String name;
  final int budget;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final String projectType;
  final Employee? projectManager;
  final String? description;

  Project({
    this.id,
    required this.name,
    required this.budget,
    required this.startDate,
    required this.expectedEndDate,
    required this.projectType,
    this.projectManager,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      budget: json['budget'] ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      expectedEndDate: json['expectedEndDate'] != null
          ? DateTime.parse(json['expectedEndDate'])
          : DateTime.now(),
      projectType: json['projectType'] ?? '',
      projectManager: json['projectManager'] != null
          ? Employee.fromJson(json['projectManager'])
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      'projectType': projectType,
      'projectManager': projectManager != null
          ? {'id': projectManager!.id}
          : null,
      'description': description,
    };
  }

  Project copyWith({
    int? id,
    String? name,
    int? budget,
    DateTime? startDate,
    DateTime? expectedEndDate,
    String? projectType,
    Employee? projectManager,
    String? description,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      projectType: projectType ?? this.projectType,
      projectManager: projectManager ?? this.projectManager,
      description: description ?? this.description,
    );
  }
}