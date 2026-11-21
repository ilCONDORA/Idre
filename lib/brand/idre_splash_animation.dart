import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_splash_timeline.dart';
import 'package:idre/brand/idre_wordmark_painter.dart';

/// The animated splash screen: the "i" appears, slides left and its tentacles bring "d", "r" and "e".
///
/// The animation starts as soon as the widget is shown. It fills the space its parent gives it
/// and fits the wordmark inside, so give it a bounded size:
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
/// - To play it again, rebuild it with a new `key` (e.g. `ValueKey(replayCount)`).
class IdreSplashAnimation extends StatefulWidget {
  const new({
    super.key,
    this.color,
    this.duration = IdreSplashTimeline.defaultDuration,
    this.clipToBounds = true,
    this.onCompleted,
  });

  /// Color of the wordmark. `null` = color of the surrounding `IconTheme`.
  final Color? color;

  /// Total duration of the animation.
  final Duration duration;

  /// Letters arrive from outside the wordmark. `true` = they appear at the edges of this widget;
  /// `false` = they can fly in from anywhere on the screen (nice in a full-screen splash).
  final bool clipToBounds;

  /// Called once, when the wordmark is complete.
  final VoidCallback? onCompleted;

  @override
  State<IdreSplashAnimation> createState() => _IdreSplashAnimationState();
}

class _IdreSplashAnimationState extends State<IdreSplashAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _assemblyController = AnimationController(vsync: this, duration: widget.duration);

  bool _hasStarted = false;

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
      _assemblyController
        ..addStatusListener(_notifyWhenCompleted)
        ..forward();
    }
  }

  void _notifyWhenCompleted(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
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
