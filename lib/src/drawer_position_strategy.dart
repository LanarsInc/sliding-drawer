import 'package:flutter/material.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';

abstract class DrawerPositionStrategy {
  DrawerPositionStrategy();

  factory DrawerPositionStrategy.fromPosition(DrawerPosition position) {
    switch (position) {
      case DrawerPosition.left:
        return LeftDrawerPositionStrategy();
      case DrawerPosition.right:
        return RightDrawerPositionStrategy();
    }
  }

  static final kMinimumDistanceToDetectDragging = 20.0;

  double onHorizontalDragDownPositionDx = 0.0;
  Offset onHorizontalDragDownOffset = Offset.zero;

  Tween<double> getContentTween({
    required double drawerWidth,
    required double screenWidth,
  });

  Tween<double> getDrawerTween({
    required double drawerWidth,
    required double screenWidth,
  });

  double calculateGlobalPositionOnOpen(Offset globalPosition);

  double calculateGlobalPositionOnClose(Offset globalPosition);

  void onPanDownOnOpen();

  void onPanDownOnClose();
}

class LeftDrawerPositionStrategy extends DrawerPositionStrategy {
  @override
  Tween<double> getContentTween({
    required double drawerWidth,
    required double screenWidth,
  }) {
    return Tween<double>(
      begin: 0,
      end: drawerWidth,
    );
  }

  @override
  Tween<double> getDrawerTween({
    required double drawerWidth,
    required double screenWidth,
  }) {
    return Tween<double>(
      begin: -drawerWidth,
      end: 0,
    );
  }

  @override
  double calculateGlobalPositionOnOpen(Offset globalPosition) {
    return globalPosition.dx - onHorizontalDragDownPositionDx;
  }

  @override
  double calculateGlobalPositionOnClose(Offset globalPosition) {
    return onHorizontalDragDownPositionDx - globalPosition.dx;
  }

  @override
  void onPanDownOnOpen() {
    onHorizontalDragDownPositionDx += DrawerPositionStrategy.kMinimumDistanceToDetectDragging;
  }

  @override
  void onPanDownOnClose() {
    onHorizontalDragDownPositionDx -= DrawerPositionStrategy.kMinimumDistanceToDetectDragging;
  }
}

class RightDrawerPositionStrategy extends DrawerPositionStrategy {
  @override
  Tween<double> getContentTween({
    required double drawerWidth,
    required double screenWidth,
  }) {
    return Tween<double>(
      begin: 0,
      end: -drawerWidth,
    );
  }

  @override
  Tween<double> getDrawerTween({
    required double drawerWidth,
    required double screenWidth,
  }) {
    return Tween<double>(
      begin: screenWidth,
      end: screenWidth - drawerWidth,
    );
  }

  @override
  double calculateGlobalPositionOnOpen(Offset globalPosition) {
    return onHorizontalDragDownPositionDx - globalPosition.dx;
  }

  @override
  double calculateGlobalPositionOnClose(Offset globalPosition) {
    return globalPosition.dx - onHorizontalDragDownPositionDx;
  }

  @override
  void onPanDownOnOpen() {
    onHorizontalDragDownPositionDx -= DrawerPositionStrategy.kMinimumDistanceToDetectDragging;
  }

  @override
  void onPanDownOnClose() {
    onHorizontalDragDownPositionDx += DrawerPositionStrategy.kMinimumDistanceToDetectDragging;
  }
}
