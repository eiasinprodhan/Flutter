import 'package:crems/entity/Employee.dart';
import 'package:crems/entity/Project.dart';

class Building {
  int? id;
  String? name;
  String? type;
  String? location;
  int? floorCount;
  int? unitCount;
  String? photo;
  Project? project;
  Employee? siteManager;

  Building({this.id, this.name, this.type, this.location, this.floorCount, this.unitCount, this.photo, this.project, this.siteManager});

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      floorCount: json['floorCount'],
      unitCount: json['unitCount'],
      photo: json['photo'],
      project: json['project'] != null ? Project.fromJson(json['project']) : null,
      siteManager: json['siteManager'] != null ? Employee.fromJson(json['siteManager']) : null,
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
      'project': project?.toJson(),
      'siteManager': siteManager?.toJson(),
    };
  }
}