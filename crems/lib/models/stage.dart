import 'floor.dart';

class Stage {
  int? id;
  String? name;
  DateTime? startDate;
  DateTime? endDate;
  Floor? floor;
  List<int>? labours;

  Stage({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.floor,
    this.labours,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      floor: json['floor'] != null
          ? Floor.fromJson(json['floor'])
          : null,
      labours: json['labours'] != null
          ? List<int>.from(json['labours'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'floor': floor != null ? {'id': floor!.id} : null,
      'labours': labours,
    };
  }
}