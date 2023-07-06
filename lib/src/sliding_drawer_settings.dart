import 'package:flutter/animation.dart';

class SlidingDrawerSettings {
  const SlidingDrawerSettings({
    this.drawerWidth = 300,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeIn,
    this.animationReverseCurve = Curves.easeOut,
    this.autocompletePercentLimit = 0.05,
  });

  final double drawerWidth;
  final Duration animationDuration;
  final Curve animationCurve;
  final Curve animationReverseCurve;
  final double autocompletePercentLimit;
}
