import 'employee.dart';
import 'project.dart';

class Building {
  int? id;
  String? name;
  String? type;
  String? location;
  int? floorCount;
  int? unitCount;
  String? photo;
  Employee? siteManager;
  Project? project;

  Building({
    this.id,
    this.name,
    this.type,
    this.location,
    this.floorCount,
    this.unitCount,
    this.photo,
    this.siteManager,
    this.project,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      floorCount: json['floorCount'],
      unitCount: json['unitCount'],
      photo: json['photo'],
      siteManager: json['siteManager'] != null
          ? Employee.fromJson(json['siteManager'])
          : null,
      project: json['project'] != null
          ? Project.fromJson(json['project'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'floorCount': floorCount,
      'unitCount': unitCount,
      'photo': photo,
      'siteManager': siteManager != null
          ? {'id': siteManager!.id}
          : null,
      'project': project != null
          ? {'id': project!.id}
          : null,
    };
  }
}