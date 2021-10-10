import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class _Cloud {
  static const _light = Color(0xFF96CDDE);
  static const _dark = Color(0xFF6AABBF);
  static const _normal = Color(0xFFACCFDA);

  static const _assets = [
    "assets/plane_indicator/cloud1.png",
    "assets/plane_indicator/cloud2.png",
    "assets/plane_indicator/cloud3.png",
    "assets/plane_indicator/cloud4.png",
  ];

  AnimationController? controller;
  final Color? color;
  final AssetImage? image;
  final double? width;
  final double? dy;
  final double? initialValue;
  final Duration? duration;
  _Cloud({
    this.color,
    this.image,
    this.width,
    this.dy,
    this.initialValue,
    this.duration,
  });
}