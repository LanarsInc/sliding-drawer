import 'package:flutter/material.dart';
import 'package:sliding_drawer/sliding_drawer.dart';

abstract class SlidingDirectionStrategy {
  SlidingDirectionStrategy();

  factory SlidingDirectionStrategy.fromDirection(SlidingDirection slideDirection) {
    switch (slideDirection) {
      case SlidingDirection.right:
        return RightSlidingDirectionStrategy();
      case SlidingDirection.left:
        return LeftSlidingDirectionStrategy();
    }
  }

  static final kMinimumDistanceToDetectDragging = 20.0;

  double onHorizontalDragDownPositionDx = 0.0;
  Offset onHorizontalDragDownOffset = Offset.zero;

  Tween<double> getMainContentTween({
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

class RightSlidingDirectionStrategy extends SlidingDirectionStrategy {
  @override
  Tween<double> getMainContentTween({
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
    onHorizontalDragDownPositionDx += SlidingDirectionStrategy.kMinimumDistanceToDetectDragging;
  }

  @override
  void onPanDownOnClose() {
    onHorizontalDragDownPositionDx -= SlidingDirectionStrategy.kMinimumDistanceToDetectDragging;
  }
}

class LeftSlidingDirectionStrategy extends SlidingDirectionStrategy {
  @override
  Tween<double> getMainContentTween({
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
    onHorizontalDragDownPositionDx -= SlidingDirectionStrategy.kMinimumDistanceToDetectDragging;
  }

  @override
  void onPanDownOnClose() {
    onHorizontalDragDownPositionDx += SlidingDirectionStrategy.kMinimumDistanceToDetectDragging;
  }
}
