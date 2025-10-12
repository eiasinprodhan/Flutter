import 'employee.dart';

class Project {
  int? id;
  String? name;
  int? budget;
  DateTime? startDate;
  DateTime? expectedEndDate;
  String? projectType;
  Employee? projectManager;
  String? description;

  Project({
    this.id,
    this.name,
    this.budget,
    this.startDate,
    this.expectedEndDate,
    this.projectType,
    this.projectManager,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      budget: json['budget'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      expectedEndDate: json['expectedEndDate'] != null
          ? DateTime.parse(json['expectedEndDate'])
          : null,
      projectType: json['projectType'],
      projectManager: json['projectManager'] != null
          ? Employee.fromJson(json['projectManager'])
          : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'startDate': startDate?.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      'projectType': projectType,
      'projectManager': projectManager != null
          ? {'id': projectManager!.id}
          : null,
      'description': description,
    };
  }
}