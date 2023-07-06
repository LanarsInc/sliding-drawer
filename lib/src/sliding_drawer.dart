import 'package:flutter/material.dart';
import 'package:sliding_drawer/src/sliding_drawer_settings.dart';
import 'package:sliding_drawer/src/utils/global_key_extension.dart';

/// The widget that displays animated sliding drawer.
class SlidingDrawer extends StatefulWidget {
  const SlidingDrawer({
    Key? key,
    required this.drawerBuilder,
    required this.mainContentBuilder,
    this.onAnimationStatusChanged,
    this.ignorePointer = false,
    this.settings = const SlidingDrawerSettings(),
  }) : super(key: key);

  /// A builder for the drawer.
  final WidgetBuilder drawerBuilder;

  /// A builder for the page content.
  final WidgetBuilder mainContentBuilder;

  /// The ignorePointer argument is used to control drawer opening/closing by
  /// horizontal dragging. If is set to true, dragging gesture will be ignored.
  final bool ignorePointer;

  /// The onAnimationStatusChanged argument is used to provide status listener
  /// for transition animation.
  final AnimationStatusListener? onAnimationStatusChanged;

  /// The settings argument stores the drawer options.
  final SlidingDrawerSettings settings;

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> with TickerProviderStateMixin {
  static final kMinimumDistanceToDetectDragging = 20.0;
  final mainContentKey = GlobalKey();

  late AnimationController _mainContentAnimationController;

  Animation<double>? mainContentAnimation;
  Animation<double>? mainContentOpacityAnimation;
  Animation<double>? drawerAnimation;

  bool isClosed = true;
  bool isClosing = false;
  bool isOpen = false;
  bool isOpening = false;

  double _currentProgressPercent = 0.0;

  double _onHorizontalDragDownPositionDx = 0.0;
  Offset _onHorizontalDragDownOffset = Offset.zero;

  /// Toggle drawer
  void toggleSlidingDrawer() => _mainContentAnimationController.isCompleted
      ? _mainContentAnimationController.reverse()
      : _mainContentAnimationController.forward();

  /// Open drawer
  void openSlidingDrawer() => _mainContentAnimationController.forward();

  /// Close drawer
  void closeSlidingDrawer() => _mainContentAnimationController.reverse();

  @override
  void initState() {
    super.initState();
    _mainContentAnimationController = AnimationController(
      vsync: this,
      duration: widget.settings.animationDuration,
    )..addStatusListener(_onAnimationStatusChanged);
    _mainContentAnimationController.reset();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (mounted) {
      isOpen = status == AnimationStatus.completed;
      isClosed = status == AnimationStatus.dismissed;
      widget.onAnimationStatusChanged?.call(status);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    final drawerWidth = widget.settings.drawerWidth;

    mainContentAnimation ??= Tween<double>(begin: 0, end: drawerWidth).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: widget.settings.animationCurve,
        reverseCurve: widget.settings.animationReverseCurve,
      ),
    );

    drawerAnimation ??= Tween<double>(begin: -drawerWidth, end: 0).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: widget.settings.animationCurve,
        reverseCurve: widget.settings.animationReverseCurve,
      ),
    );

    mainContentOpacityAnimation ??= Tween<double>(begin: 1, end: 0.5).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _mainContentAnimationController
      ..removeStatusListener(_onAnimationStatusChanged)
      ..addStatusListener(_onAnimationStatusChanged);

    var settings = widget.settings;
    var oldSettings = oldWidget.settings;
    if (settings.drawerWidth != oldSettings.drawerWidth ||
        settings.animationCurve != oldSettings.animationCurve ||
        settings.animationReverseCurve != oldSettings.animationReverseCurve) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final drawerWidth = widget.settings.drawerWidth;

    mainContentAnimation = Tween<double>(begin: 0, end: drawerWidth).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );

    drawerAnimation = Tween<double>(begin: -drawerWidth, end: 0).animate(
      CurvedAnimation(
        parent: _mainContentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mainContentKey.globalPaintBounds!.contains(_onHorizontalDragDownOffset)) {
                closeSlidingDrawer();
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
              final panelWidth = widget.settings.drawerWidth;
              if (isOpening) {
                final globalPosition = details.globalPosition.dx - _onHorizontalDragDownPositionDx;
                double progress = globalPosition / panelWidth;
                _animate(_normalizeProgressValue(progress));
              } else {
                final globalPosition = _onHorizontalDragDownPositionDx - details.globalPosition.dx;
                double progress = 1 - globalPosition / panelWidth;
                _animate(_normalizeProgressValue(progress));
              }
            },
            child: Stack(
              children: [
                _MainContent(
                  shouldAbsorbPointer: isOpen,
                  animationController: _mainContentAnimationController,
                  animation: mainContentAnimation,
                  mainContentKey: mainContentKey,
                  opacityAnimation: mainContentOpacityAnimation,
                  contentBuilder: widget.mainContentBuilder,
                ),
                _Drawer(
                  drawerBuilder: widget.drawerBuilder,
                  shouldIgnorePointer: isClosed,
                  animationController: _mainContentAnimationController,
                  animation: drawerAnimation,
                  drawerWidth: widget.settings.drawerWidth,
                ),
              ],
            ),
          ),
        );
      },
    );
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

    final autocompletePercentLimit = widget.settings.autocompletePercentLimit;
    if (isOpening) {
      if (_currentProgressPercent >= autocompletePercentLimit) {
        openSlidingDrawer();
      } else {
        closeSlidingDrawer();
      }
      return;
    }

    if (isClosing) {
      if (_currentProgressPercent <= (1 - autocompletePercentLimit)) {
        closeSlidingDrawer();
      } else {
        openSlidingDrawer();
      }
      return;
    }
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

  double _normalizeProgressValue(double position) {
    if (position > 1.0) {
      position = 1.0;
    }
    if (position < 0.0) {
      position = 0.0;
    }
    return position;
  }

  void _animate(double percent) {
    if (widget.ignorePointer) return;

    _currentProgressPercent = percent;
    _mainContentAnimationController.value = percent;
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    Key? key,
    required this.shouldAbsorbPointer,
    required this.animationController,
    required this.animation,
    required this.mainContentKey,
    required this.opacityAnimation,
    required this.contentBuilder,
  }) : super(key: key);

  final WidgetBuilder contentBuilder;
  final bool shouldAbsorbPointer;
  final GlobalKey<State<StatefulWidget>> mainContentKey;
  final AnimationController animationController;
  final Animation? animation;
  final Animation? opacityAnimation;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: shouldAbsorbPointer,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(animation!.value, 0),
            child: child,
          );
        },
        child: Container(
          key: mainContentKey,
          width: double.infinity,
          height: double.infinity,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (_, child) {
              return Opacity(
                opacity: opacityAnimation!.value,
                child: contentBuilder(context),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({
    Key? key,
    required this.drawerBuilder,
    required this.shouldIgnorePointer,
    required this.animationController,
    required this.animation,
    required this.drawerWidth,
  }) : super(key: key);

  final WidgetBuilder drawerBuilder;
  final bool shouldIgnorePointer;
  final AnimationController animationController;
  final Animation? animation;
  final double drawerWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return IgnorePointer(
          ignoring: shouldIgnorePointer,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (_, child) {
              return Transform.translate(
                offset: Offset(animation!.value, 0),
                child: child,
              );
            },
            child: Container(
              width: drawerWidth,
              height: constraints.maxHeight,
              child: drawerBuilder(context),
            ),
          ),
        );
      },
    );
  }
}