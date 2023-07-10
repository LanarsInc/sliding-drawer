import 'package:flutter/material.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';
import 'package:flutter_sliding_drawer/src/drawer_position_strategy.dart';
import 'package:flutter_sliding_drawer/src/utils/global_key_extension.dart';

/// The widget that displays animated sliding drawer.
class SlidingDrawer extends StatefulWidget {
  const SlidingDrawer({
    Key? key,
    required this.drawerBuilder,
    required this.contentBuilder,
    this.onAnimationStatusChanged,
    this.ignorePointer = false,
    this.settings = const SlidingDrawerSettings(),
    this.position = DrawerPosition.left,
  }) : super(key: key);

  /// A builder for the drawer.
  final WidgetBuilder drawerBuilder;

  /// A builder for the page content.
  final WidgetBuilder contentBuilder;

  /// The ignorePointer argument is used to control drawer opening/closing by
  /// horizontal dragging. If is set to true, dragging gesture will be ignored.
  final bool ignorePointer;

  /// The onAnimationStatusChanged argument is used to provide status listener
  /// for transition animation.
  final AnimationStatusListener? onAnimationStatusChanged;

  /// The settings argument stores the drawer options.
  final SlidingDrawerSettings settings;

  /// Specifies the drawer position. Defaults to [DrawerPosition.left]
  final DrawerPosition position;

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> with TickerProviderStateMixin {
  static final kMinimumDistanceToDetectDragging = 20.0;
  final contentKey = GlobalKey();

  late AnimationController _contentAnimationController;
  late DrawerPositionStrategy _positionStrategy;

  Animation<double>? contentAnimation;
  Animation<double>? contentOpacityAnimation;
  Animation<double>? drawerAnimation;

  bool isClosed = true;
  bool isClosing = false;
  bool isOpen = false;
  bool isOpening = false;

  double _currentProgressPercent = 0.0;

  /// Toggle drawer
  void toggleSlidingDrawer() =>
      _contentAnimationController.isCompleted ? closeSlidingDrawer() : openSlidingDrawer();

  /// Open drawer
  void openSlidingDrawer() {
    _closeKeyboard();
    _contentAnimationController.forward();
  }

  /// Close drawer
  void closeSlidingDrawer() {
    _closeKeyboard();
    _contentAnimationController.reverse();
  }

  void _closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: widget.settings.animationDuration,
    )..addStatusListener(_onAnimationStatusChanged);
    _contentAnimationController.reset();
    _positionStrategy = DrawerPositionStrategy.fromPosition(widget.position);
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
    final screenWidth = MediaQuery.sizeOf(context).width;

    contentAnimation ??= _positionStrategy
        .getContentTween(
          drawerWidth: drawerWidth,
          screenWidth: screenWidth,
        )
        .animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: widget.settings.animationCurve,
            reverseCurve: widget.settings.animationReverseCurve,
          ),
        );

    drawerAnimation ??= _positionStrategy
        .getDrawerTween(
          drawerWidth: drawerWidth,
          screenWidth: screenWidth,
        )
        .animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: widget.settings.animationCurve,
            reverseCurve: widget.settings.animationReverseCurve,
          ),
        );

    contentOpacityAnimation ??= Tween<double>(begin: 1, end: 0.5).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _contentAnimationController
      ..removeStatusListener(_onAnimationStatusChanged)
      ..addStatusListener(_onAnimationStatusChanged);

    var settings = widget.settings;
    var oldSettings = oldWidget.settings;
    if (settings.drawerWidth != oldSettings.drawerWidth ||
        settings.animationCurve != oldSettings.animationCurve ||
        settings.animationReverseCurve != oldSettings.animationReverseCurve) {
      _updateAnimation();
    }
    if (widget.position != oldWidget.position) {
      _positionStrategy = DrawerPositionStrategy.fromPosition(widget.position);
    }
  }

  void _updateAnimation() {
    final drawerWidth = widget.settings.drawerWidth;
    final screenWidth = MediaQuery.sizeOf(context).width;

    contentAnimation = _positionStrategy
        .getContentTween(
          drawerWidth: drawerWidth,
          screenWidth: screenWidth,
        )
        .animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.easeIn,
            reverseCurve: Curves.easeOut,
          ),
        );

    drawerAnimation = _positionStrategy
        .getDrawerTween(
          drawerWidth: drawerWidth,
          screenWidth: screenWidth,
        )
        .animate(
          CurvedAnimation(
            parent: _contentAnimationController,
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
              if (contentKey.globalPaintBounds!
                  .contains(_positionStrategy.onHorizontalDragDownOffset)) {
                closeSlidingDrawer();
              }
            },
            onHorizontalDragDown: (details) {
              _positionStrategy.onHorizontalDragDownOffset = details.globalPosition;
              _positionStrategy.onHorizontalDragDownPositionDx = details.globalPosition.dx;
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
              double progress;

              if (isOpening) {
                final globalPosition =
                    _positionStrategy.calculateGlobalPositionOnOpen(details.globalPosition);
                progress = globalPosition / panelWidth;
              } else {
                final globalPosition =
                    _positionStrategy.calculateGlobalPositionOnClose(details.globalPosition);
                progress = 1 - globalPosition / panelWidth;
              }

              _animate(_normalizeProgressValue(progress));
            },
            child: Stack(
              children: [
                _Content(
                  shouldAbsorbPointer: isOpen,
                  animationController: _contentAnimationController,
                  animation: contentAnimation,
                  contentKey: contentKey,
                  opacityAnimation: contentOpacityAnimation,
                  contentBuilder: widget.contentBuilder,
                  barrierColor: widget.settings.barrierColor,
                ),
                _Drawer(
                  drawerBuilder: widget.drawerBuilder,
                  shouldIgnorePointer: isClosed,
                  animationController: _contentAnimationController,
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
    _contentAnimationController.reset();
    _contentAnimationController.dispose();
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
    isOpening = contentKey.globalPaintBounds!.left == 0;
    isClosing = !isOpening;
  }

  void _normalizeOnPanDownPosition() {
    if (isOpening) {
      _positionStrategy.onPanDownOnOpen();
    } else {
      _positionStrategy.onPanDownOnClose();
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
    _contentAnimationController.value = percent;
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.shouldAbsorbPointer,
    required this.animationController,
    required this.animation,
    required this.contentKey,
    required this.opacityAnimation,
    required this.contentBuilder,
    this.barrierColor,
  }) : super(key: key);

  final WidgetBuilder contentBuilder;
  final bool shouldAbsorbPointer;
  final GlobalKey<State<StatefulWidget>> contentKey;
  final AnimationController animationController;
  final Animation? animation;
  final Animation? opacityAnimation;
  final Color? barrierColor;

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
          key: contentKey,
          width: double.infinity,
          height: double.infinity,
          color: barrierColor,
          child: barrierColor == null
              ? contentBuilder(context)
              : AnimatedBuilder(
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
