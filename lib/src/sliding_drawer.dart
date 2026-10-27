import 'package:flutter/material.dart';

import 'drawer_position.dart';
import 'drawer_position_strategy.dart';
import 'sliding_drawer_settings.dart';
import 'utils/global_key_extension.dart';

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

class SlidingDrawerState extends State<SlidingDrawer>
    with TickerProviderStateMixin {
  final contentKey = GlobalKey();

  late AnimationController _contentAnimationController;
  late DrawerPositionStrategy _positionStrategy;
  late final CurvedAnimation _curvedAnimation;

  late Animation<double> contentAnimation;
  late Animation<double> contentOpacityAnimation;
  late Animation<double> drawerAnimation;

  bool isClosed = true;
  bool isClosing = false;
  bool isOpen = false;
  bool isOpening = false;

  double _currentProgressPercent = 0.0;

  void _toggleSlidingDrawer() => _contentAnimationController.isCompleted
      ? _closeSlidingDrawer()
      : _openSlidingDrawer();

  void _openSlidingDrawer() {
    _closeKeyboard();
    _contentAnimationController.forward();
  }

  void _closeSlidingDrawer() {
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
    _positionStrategy = DrawerPositionStrategy.fromPosition(widget.position);

    _curvedAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: widget.settings.animationCurve,
      reverseCurve: widget.settings.animationReverseCurve,
    );
    contentOpacityAnimation =
        Tween<double>(begin: 1, end: 0.5).animate(_curvedAnimation);
    _updateAnimations();
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
  void didUpdateWidget(covariant SlidingDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final settings = widget.settings;
    final oldSettings = oldWidget.settings;

    if (settings.animationDuration != oldSettings.animationDuration) {
      _contentAnimationController.duration = settings.animationDuration;
    }
    if (settings.animationCurve != oldSettings.animationCurve) {
      _curvedAnimation.curve = settings.animationCurve;
    }
    if (settings.animationReverseCurve != oldSettings.animationReverseCurve) {
      _curvedAnimation.reverseCurve = settings.animationReverseCurve;
    }
    if (widget.position != oldWidget.position) {
      _positionStrategy = DrawerPositionStrategy.fromPosition(widget.position);
    }
    if (settings.drawerWidth != oldSettings.drawerWidth ||
        widget.position != oldWidget.position) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final drawerWidth = widget.settings.drawerWidth;

    contentAnimation = _positionStrategy
        .getContentTween(drawerWidth: drawerWidth)
        .animate(_curvedAnimation);

    drawerAnimation = _positionStrategy
        .getDrawerTween(drawerWidth: drawerWidth)
        .animate(_curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final contentBounds = contentKey.globalPaintBounds;
        final containsDragOffset = contentBounds
                ?.contains(_positionStrategy.onHorizontalDragDownOffset) ??
            false;
        if (containsDragOffset) {
          _closeSlidingDrawer();
        }
      },
      onHorizontalDragDown: (details) {
        _positionStrategy.onHorizontalDragDownOffset = details.globalPosition;
        _positionStrategy.onHorizontalDragDownPositionDx =
            details.globalPosition.dx;
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
          final globalPosition = _positionStrategy
              .calculateGlobalPositionOnOpen(details.globalPosition);
          progress = globalPosition / panelWidth;
        } else {
          final globalPosition = _positionStrategy
              .calculateGlobalPositionOnClose(details.globalPosition);
          progress = 1 - globalPosition / panelWidth;
        }

        _animate(_normalizeProgressValue(progress));
      },
      child: Stack(
        fit: StackFit.expand,
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
            alignment: _positionStrategy.drawerAlignment,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _contentAnimationController
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    super.dispose();
  }

  void _openOrClosePanel() {
    if (widget.ignorePointer) return;

    final autocompletePercentLimit = widget.settings.autocompletePercentLimit;
    if (isOpening) {
      if (_currentProgressPercent >= autocompletePercentLimit) {
        _openSlidingDrawer();
      } else {
        _closeSlidingDrawer();
      }
      return;
    }

    if (isClosing) {
      if (_currentProgressPercent <= (1 - autocompletePercentLimit)) {
        _closeSlidingDrawer();
      } else {
        _openSlidingDrawer();
      }
      return;
    }
  }

  void _detectDirection() {
    isOpening = _contentAnimationController.isDismissed;
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
  final Animation<double> animation;
  final Animation<double> opacityAnimation;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: shouldAbsorbPointer,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(animation.value, 0),
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
                      opacity: opacityAnimation.value,
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
    required this.alignment,
  }) : super(key: key);

  final WidgetBuilder drawerBuilder;
  final bool shouldIgnorePointer;
  final AnimationController animationController;
  final Animation<double> animation;
  final double drawerWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: shouldIgnorePointer,
      child: Align(
        alignment: alignment,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (_, child) {
            return Transform.translate(
              offset: Offset(animation.value, 0),
              child: child,
            );
          },
          child: SizedBox(
            width: drawerWidth,
            height: double.infinity,
            child: drawerBuilder(context),
          ),
        ),
      ),
    );
  }
}

extension SlidingDrawerGlobalKeyExtension on GlobalKey<SlidingDrawerState> {
  /// Open drawer
  void open() => currentState!._openSlidingDrawer();

  /// Close drawer
  void close() => currentState!._closeSlidingDrawer();

  /// Toggle drawer
  void toggle() => currentState!._toggleSlidingDrawer();
}
