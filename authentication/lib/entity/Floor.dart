import 'package:crems/entity/Building.dart';

class Floor {
  int? id;
  String? name;
  String? expectedEndDate;
  Building? building;

  Floor({this.id, this.name, this.expectedEndDate, this.building});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      name: json['name'],
      expectedEndDate: json['expectedEndDate'],
      building: json['building'] != null ? Building.fromJson(json['building']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expectedEndDate': expectedEndDate,
      'building': building?.toJson(),
    };
  }
}