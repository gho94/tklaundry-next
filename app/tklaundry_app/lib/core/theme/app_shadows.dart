import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const sm = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
