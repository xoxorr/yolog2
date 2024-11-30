import 'package:flutter/material.dart';

enum ColorBlindType {
  normal,
  protanopia, // 적색맹
  deuteranopia, // 녹색맹
  tritanopia, // 청색맹
}

class ColorBlind extends StatelessWidget {
  final Widget child;
  final ColorBlindType type;

  const ColorBlind({
    super.key,
    required this.child,
    this.type = ColorBlindType.normal,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ColorBlindType.normal) {
      return child;
    }

    return ColorFiltered(
      colorFilter: _getColorFilter(type),
      child: child,
    );
  }

  ColorFilter _getColorFilter(ColorBlindType type) {
    switch (type) {
      case ColorBlindType.protanopia:
        return const ColorFilter.matrix([
          0.567,
          0.433,
          0,
          0,
          0,
          0.558,
          0.442,
          0,
          0,
          0,
          0,
          0.242,
          0.758,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ColorBlindType.deuteranopia:
        return const ColorFilter.matrix([
          0.625,
          0.375,
          0,
          0,
          0,
          0.7,
          0.3,
          0,
          0,
          0,
          0,
          0.3,
          0.7,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ColorBlindType.tritanopia:
        return const ColorFilter.matrix([
          0.95,
          0.05,
          0,
          0,
          0,
          0,
          0.433,
          0.567,
          0,
          0,
          0,
          0.475,
          0.525,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      default:
        return const ColorFilter.matrix([
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }
}
