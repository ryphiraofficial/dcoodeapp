import 'package:flutter/material.dart';
import '../constants.dart';

class AppLogo extends StatelessWidget {
  final double fontSize;
  final double capsuleWidth;
  final double capsuleHeight;
  final double borderThickness;
  final Color textColor;

  const AppLogo({
    super.key,
    this.fontSize = 28,
    this.capsuleWidth = 50,
    this.capsuleHeight = 24,
    this.borderThickness = 4,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'DC',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: capsuleWidth,
          height: capsuleHeight,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: borderThickness),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'DE',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
