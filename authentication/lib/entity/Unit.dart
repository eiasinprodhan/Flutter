import 'package:crems/entity/Building.dart';
import 'package:crems/entity/Floor.dart';

class Unit {
  int? id;
  String? unitNumber;
  int? area;
  int? bedrooms;
  int? bathrooms;
  Building? building;
  Floor? floor;
  List<String>? photoUrls;
  int? price;
  int? interestRate;
  String? name;
  bool? booked;

  Unit({this.id, this.unitNumber, this.area, this.bedrooms, this.bathrooms, this.building, this.floor, this.photoUrls, this.price, this.interestRate, this.name, this.booked});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      unitNumber: json['unitNumber'],
      area: json['area'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      building: json['building'] != null ? Building.fromJson(json['building']) : null,
      floor: json['floor'] != null ? Floor.fromJson(json['floor']) : null,
      photoUrls: json['photoUrls'],
      price: json['price'],
      interestRate: json['interestRate'],
      name: json['name'],
      booked: json['booked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitNumber': unitNumber,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'building': building?.toJson(),
      'floor': floor?.toJson(),
      'photoUrls': photoUrls,
      'price': price,
      'interestRate': interestRate,
      'name': name,
      'booked': booked,
    };
  }
}