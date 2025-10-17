import 'package:crems/entity/Floor.dart';

class Stage {
  int? id;
  String? name;
  String? startDate;
  String? endDate;
  Floor? floor;
  List<int>? labours;

  Stage({this.id, this.name, this.startDate, this.endDate, this.floor, this.labours});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      floor: json['floor'] != null ? Floor.fromJson(json['floor']) : null,
      labours: json['labours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'floor': floor?.toJson(),
      'labours': labours,
    };
  }
}