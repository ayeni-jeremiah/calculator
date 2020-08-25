import 'package:flutter/cupertino.dart';

class Hex {
  static Color color(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
