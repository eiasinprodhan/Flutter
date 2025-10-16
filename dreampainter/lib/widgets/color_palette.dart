import 'package:flutter/material.dart';
import 'package:dreampainter/constants/app_colors.dart';

class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      height: 80,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.colorPalette.length,
        itemBuilder: (context, index) {
          final color = AppColors.colorPalette[index];
          final bool isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              width: isSelected ? 55 : 50,
              height: isSelected ? 55 : 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == Colors.white ? AppColors.primaryText.withOpacity(0.5) : Colors.transparent,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? AppColors.primary.withOpacity(0.7) : Colors.black.withOpacity(0.2),
                    blurRadius: isSelected ? 8 : 4,
                    spreadRadius: isSelected ? 2 : 1,
                  )
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : null,
            ),
          );
        },
      ),
    );
  }
}