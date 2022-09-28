import 'dart:math';

import 'package:flutter/material.dart';

/// Extension for Color in prefix email
extension ExtendedColors on Color {
  static get randomColor {
    return Color((Random().nextDouble() * 0xDDDDDD).toInt()).withOpacity(1.0);
  }

  static get randomInCollectionColor {
    // generates a new Random object
    final _random = Random();

    // generate a random index based on the list length
    // and use it to retrieve the element
    final list = [
      const Color(0xFFFBBF24),
      const Color(0xFFF43F5E),
      const Color(0xFF0EA5E9),
      const Color(0xFF8B5CF6),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
    ];
    return list[_random.nextInt(list.length)];
  }
}
