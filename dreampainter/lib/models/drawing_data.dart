import 'package:flutter/material.dart';

class DrawingCategory {
  final String name;
  final IconData icon;
  final List<String> drawings;

  DrawingCategory({required this.name, required this.icon, required this.drawings});
}

final List<DrawingCategory> categories = [
  DrawingCategory(
    name: 'Animals',
    icon: Icons.pets,
    drawings: ['svgs/animals/cat.svg', 'assets/svgs/animals/dog.svg', 'assets/svgs/animals/lion.svg'],
  ),
  DrawingCategory(
    name: 'Vehicles',
    icon: Icons.directions_car,
    drawings: ['assets/svgs/vehicles/car.svg', 'assets/svgs/vehicles/rocket.svg', 'assets/svgs/vehicles/bus.svg'],
  ),
];