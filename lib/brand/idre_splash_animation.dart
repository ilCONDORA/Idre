import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_splash_timeline.dart';
import 'package:idre/brand/idre_wordmark_painter.dart';

/// The animated splash screen: the "i" appears, slides left and its tentacles bring "d", "r" and "e".
///
/// The animation starts right after its first frame is drawn (plus [pauseBeforeStarting], if any).
/// It fills the space its parent gives it and fits the wordmark inside, so give it a bounded size:
///
/// ```dart
/// Center(
///   child: SizedBox(
///     width: 280,
///     height: 220,
///     child: IdreSplashAnimation(onCompleted: () => context.go('/home')),
///   ),
/// )
/// ```
///
/// - If the user disabled animations in the system settings, the final wordmark is shown at once.
/// - On platforms with a native splash screen, set [startsFromNativeSplashFrame] to `true`: the "i" is
///   already on screen (drawn by the native splash), so the animation skips the pop-in.
/// - To play it again, rebuild it with a new `key` (e.g. `ValueKey(replayCount)`).
class IdreSplashAnimation extends StatefulWidget {
  const new({
    super.key,
    this.color,
    this.duration = IdreSplashTimeline.defaultDuration,
    this.clipToBounds = true,
    this.startsFromNativeSplashFrame = false,
    this.pauseBeforeStarting = Duration.zero,
    this.onCompleted,
  });

  /// Color of the wordmark. `null` = color of the surrounding `IconTheme`.
  final Color? color;

  /// Total duration of the animation.
  final Duration duration;

  /// Letters arrive from outside the wordmark. `true` = they appear at the edges of this widget;
  /// `false` = they can fly in from anywhere on the screen (nice in a full-screen splash).
  final bool clipToBounds;

  /// `true` = start from [IdreSplashTimeline.handOffFromNativeSplashProgress]: the "i" is already at rest
  /// in the center, exactly like the image of the native splash screen, and the first thing that moves is
  /// the slide to the left. The remaining part lasts about 85 % of [duration].
  ///
  /// `false` = full choreography, the "i" pops in first (desktop, which has no native splash).
  final bool startsFromNativeSplashFrame;

  /// How long the first frame stays still before the animation starts, counted from the moment that frame is
  /// drawn (not from the creation of the widget).
  ///
  /// Counting from the first frame matters: the very first frames of an app are the slowest (especially in debug
  /// builds), and a timer started earlier would be partly "eaten" by them. Use
  /// [IdreSplashTimeline.pauseAfterNativeSplashHandOff] together with [startsFromNativeSplashFrame].
  final Duration pauseBeforeStarting;

  /// Called once, when the wordmark is complete.
  final VoidCallback? onCompleted;

  @override
  State<IdreSplashAnimation> createState() => _IdreSplashAnimationState();
}

class _IdreSplashAnimationState extends State<IdreSplashAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _assemblyController = AnimationController(vsync: this, duration: widget.duration);

  bool _hasStarted = false;

  /// Waits [IdreSplashAnimation.pauseBeforeStarting] before the animation starts moving.
  Timer? _pauseBeforeStartingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is only available from here (not in initState), so the animation starts here, once.
    if (_hasStarted) {
      return;
    }
    _hasStarted = true;

    final bool areAnimationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (areAnimationsDisabled) {
      // Jump to the final wordmark. The status listener is NOT registered in this branch: setting the value
      // to 1 marks the controller as "completed", and a listener would call onCompleted a second time.
      _assemblyController.value = 1;
      // Notify after this frame: calling the parent during build could trigger a navigation too early.
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) => widget.onCompleted?.call());
    } else {
      // Show the start frame at once (with a native splash: the same "i" as the native image)…
      _assemblyController.value = widget.startsFromNativeSplashFrame
          ? IdreSplashTimeline.handOffFromNativeSplashProgress
          : 0;
      // …and register the listener only now, so setting the start value can never call onCompleted.
      _assemblyController.addStatusListener(_notifyWhenCompleted);
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) => _startAfterThePause());
    }
  }

  /// Called once the start frame has been drawn: waits [IdreSplashAnimation.pauseBeforeStarting], then plays.
  void _startAfterThePause() {
    if (!mounted) {
      return;
    }
    _pauseBeforeStartingTimer = Timer(widget.pauseBeforeStarting, () {
      if (mounted) {
        _assemblyController.forward();
      }
    });
  }

  void _notifyWhenCompleted(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _pauseBeforeStartingTimer?.cancel();
    _assemblyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget animatedWordmark = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: IdreWordmarkPainter(
          color: widget.color ?? IconTheme.of(context).color ?? const Color(0xFF000000),
          assemblyProgress: _assemblyController,
        ),
      ),
    );

    return Semantics(
      label: 'Idre',
      image: true,
      child: widget.clipToBounds ? ClipRect(child: animatedWordmark) : animatedWordmark,
    );
  }
}
