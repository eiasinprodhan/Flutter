import 'building.dart';

class Floor {
  int? id;
  String? name;
  DateTime? expectedEndDate;
  Building? building;

  Floor({
    this.id,
    this.name,
    this.expectedEndDate,
    this.building,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      name: json['name'],
      expectedEndDate: json['expectedEndDate'] != null
          ? DateTime.parse(json['expectedEndDate'])
          : null,
      building: json['building'] != null
          ? Building.fromJson(json['building'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      // When sending data, we only need to send the ID of the related entity
      'building': building != null ? {'id': building!.id} : null,
    };
  }
}