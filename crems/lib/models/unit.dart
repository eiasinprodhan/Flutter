import 'building.dart';
import 'floor.dart';

class Unit {
  int? id;
  String? unitNumber;
  double? area;
  int? bedrooms;
  int? bathrooms;
  bool isBooked;
  Building? building;
  Floor? floor;
  List<String>? photoUrls;
  double? price;
  double? interestRate;

  Unit({
    this.id,
    this.unitNumber,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.isBooked = false,
    this.building,
    this.floor,
    this.photoUrls,
    this.price,
    this.interestRate,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      unitNumber: json['unitNumber'],
      area: (json['area'] as num?)?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      // This is correct for receiving data from the backend
      isBooked: json['booked'] ?? json['isBooked'] ?? false,
      building: json['building'] != null ? Building.fromJson(json['building']) : null,
      floor: json['floor'] != null ? Floor.fromJson(json['floor']) : null,
      photoUrls: json['photoUrls'] != null ? List<String>.from(json['photoUrls']) : [],
      price: (json['price'] as num?)?.toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitNumber': unitNumber,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      // ✅ *** THIS IS THE FIX ***
      // Change the key being sent to the backend from 'isBooked' to 'booked'
      'booked': isBooked,
      'building': building != null ? {'id': building!.id} : null,
      'floor': floor != null ? {'id': floor!.id} : null,
      // You can include existing photo URLs if your update logic needs them
      'photoUrls': photoUrls,
      'price': price,
      'interestRate': interestRate,
    };
  }
}