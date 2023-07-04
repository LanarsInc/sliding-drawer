import 'dart:ui';

import 'package:flutter/material.dart';

class SidePanelContainer extends StatefulWidget {
  final bool ignorePointer;

  ///TODO consider use builders instead of Widgets (to provide state reference outside)
  final Widget sidePanel;
  final Widget mainContent;
  final Function(AnimationStatus)? onStatusChanged;

  const SidePanelContainer({
    Key? key,
    required this.sidePanel,
    required this.mainContent,
    this.onStatusChanged,
    this.ignorePointer = false,
  }) : super(key: key);

  @override
  SidePanelContainerState createState() => SidePanelContainerState();
}

class SidePanelContainerState extends State<SidePanelContainer>
    with TickerProviderStateMixin {
  static final kMinimumDistanceToDetectDragging = 20.0;
  static final kAnimationDuration = const Duration(milliseconds: 250);
  final mainContentKey = GlobalKey();

  late AnimationController _mainContentAnimationController;

  Animation? mainContentAnimation;
  Animation? mainContentOpacityAnimation;
  Animation? sidePanelAnimation;

  bool isClosed = true;
  bool isClosing = false;
  bool isOpen = false;
  bool isOpening = false;

  double _currentProgressPercent = .0;

  double _onHorizontalDragDownPositionDx = .0;
  Offset _onHorizontalDragDownOffset = Offset.zero;

  double _sidePanelWidthToScreenWidthRation = .76;
  double _sidePanelAutocompletePercentLimit = .05;

  /// Toggle drawer
  void toggleSidePanel() => _mainContentAnimationController.isCompleted
      ? _mainContentAnimationController.reverse()
      : _mainContentAnimationController.forward();

  /// Open drawer
  void openSidePanel() => _mainContentAnimationController.forward();

  /// Close drawer
  void closeSidePanel() => _mainContentAnimationController.reverse();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mainContentKey.globalPaintBounds!
                  .contains(_onHorizontalDragDownOffset)) {
                closeSidePanel();
              }
            },
            onHorizontalDragDown: (details) {
              _onHorizontalDragDownOffset = details.globalPosition;
              _onHorizontalDragDownPositionDx = details.globalPosition.dx;
            },
            onHorizontalDragStart: (details) {
              _detectDirection();
              _normalizeOnPanDownPosition();
            },
            onHorizontalDragEnd: (details) {
              _openOrClosePanel();
            },
            onHorizontalDragUpdate: (details) {
              final expandedWidth =
                  constraints.maxWidth * _sidePanelWidthToScreenWidthRation;
              if (isOpening) {
                final globalPosition =
                    details.globalPosition.dx - _onHorizontalDragDownPositionDx;
                double progress = globalPosition / expandedWidth;
                _animate(normalizeProgressValue(progress));
              } else {
                final globalPosition =
                    _onHorizontalDragDownPositionDx - details.globalPosition.dx;
                double progress = 1 - globalPosition / expandedWidth;
                _animate(normalizeProgressValue(progress));
              }
            },
            child: Stack(
              children: [
                mainContent(),
                sidePanel(constraints),
              ],
            )),
      );
    });
  }

  Widget mainContent() {
    return AbsorbPointer(
      absorbing: isOpen,
      child: AnimatedBuilder(
        animation: _mainContentAnimationController,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(mainContentAnimation!.value, 0),
            child: child,
          );
        },
        child: Container(
          key: mainContentKey,
          width: double.infinity,
          height: double.infinity,
          child: AnimatedBuilder(
            animation: _mainContentAnimationController,
            builder: (_, child) {
              return Opacity(
                opacity: mainContentOpacityAnimation!.value,
                child: widget.mainContent,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget sidePanel(BoxConstraints constraints) {
    return IgnorePointer(
      ignoring: isClosed,
      child: AnimatedBuilder(
        animation: _mainContentAnimationController,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(sidePanelAnimation!.value, 0),
            child: child,
          );
        },
        child: Container(
          width: constraints.maxWidth * _sidePanelWidthToScreenWidthRation,
          height: constraints.maxHeight,
          child: widget.sidePanel,
        ),
      ),
    );
  }

  double normalizeProgressValue(double position) {
    if (position > 1.0) {
      position = 1.0;
    }
    if (position < 0.0) {
      position = 0.0;
    }
    return position;
  }

  void _detectDirection() {
    isOpening = mainContentKey.globalPaintBounds!.left == 0;
    isClosing = !isOpening;
  }

  void _normalizeOnPanDownPosition() {
    if (isOpening) {
      _onHorizontalDragDownPositionDx += kMinimumDistanceToDetectDragging;
    } else {
      _onHorizontalDragDownPositionDx -= kMinimumDistanceToDetectDragging;
    }
  }

  @override
  void initState() {
    super.initState();
    _mainContentAnimationController = AnimationController(
      vsync: this,
      duration: kAnimationDuration,
    )..addStatusListener((AnimationStatus status) {
        if (mounted) {
          isOpen = status == AnimationStatus.completed;
          isClosed = status == AnimationStatus.dismissed;
          widget.onStatusChanged?.call(status);
          setState(() {});
        }
      });
    _mainContentAnimationController.reset();
  }

  @override
  void didChangeDependencies() {
    final expandedWidth =
        MediaQuery.of(context).size.width * _sidePanelWidthToScreenWidthRation;

    mainContentAnimation ??=
        Tween<double>(begin: 0, end: expandedWidth).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    sidePanelAnimation ??= Tween<double>(begin: -expandedWidth, end: 0).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    mainContentOpacityAnimation ??= Tween<double>(begin: 1, end: .5).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _mainContentAnimationController.reset();
    _mainContentAnimationController.dispose();
    isOpen = false;
    isClosed = true;
  }

  void _openOrClosePanel() {
    if (widget.ignorePointer) return;

    if (isOpening) {
      if (_currentProgressPercent >= _sidePanelAutocompletePercentLimit) {
        openSidePanel();
      } else {
        closeSidePanel();
      }
      return;
    }

    if (isClosing) {
      if (_currentProgressPercent <= (1 - _sidePanelAutocompletePercentLimit)) {
        closeSidePanel();
      } else {
        openSidePanel();
      }
      return;
    }
  }

  void _animate(double percent) {
    if (widget.ignorePointer) return;

    _currentProgressPercent = percent;
    _mainContentAnimationController.value = percent;
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();

    if (translation != null) {
      return renderObject!.paintBounds.shift(
        Offset(translation.x, translation.y),
      );
    } else {
      return null;
    }
  }
}
