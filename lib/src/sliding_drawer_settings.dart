import 'package:flutter/material.dart';

/// A data class that is used to pass parameters for SlidingDrawer.
class SlidingDrawerSettings {
  const SlidingDrawerSettings({
    this.drawerWidth = 300,
    this.barrierColor = Colors.black54,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeIn,
    this.animationReverseCurve = Curves.easeOut,
    this.autocompletePercentLimit = 0.05,
  });

  /// The drawerWidth argument is used to specify drawer width.
  final double drawerWidth;

  /// The barrierColor argument is used to specify barrier color when drawer is open.
  /// To make the barrier transparent, set the property to null.
  final Color? barrierColor;

  /// The animationDuration argument is used to specify duration of
  /// sliding drawer opening/closing animation.
  final Duration animationDuration;

  /// The animationCurve argument is used to specify curve to use in the forward
  /// direction of drawer animation.
  final Curve animationCurve;

  /// The animationReverseCurve argument is used to specify curve to use in
  /// the reverse direction of drawer animation.
  final Curve? animationReverseCurve;

  /// The autocompletePercentLimit argument is used to specify the percentage of the size
  /// of the drawer that the user has moved to, after which the drawer will automatically
  /// complete opening/closing.
  final double autocompletePercentLimit;
}
