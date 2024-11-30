import 'package:flutter/material.dart';

class TextScale extends StatelessWidget {
  final Widget child;
  final double scale;

  const TextScale({
    super.key,
    required this.child,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: scale,
      ),
      child: child,
    );
  }

  static double get small => 0.8;
  static double get normal => 1.0;
  static double get large => 1.2;
  static double get extraLarge => 1.4;
}
