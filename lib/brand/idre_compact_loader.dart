import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_icon.dart';
import 'package:idre/brand/idre_tentacle_position.dart';

/// Small loader: the "i" alone, its tentacles lighting up one after the other (a cascade),
/// then switching off one after the other in the same order, and starting again.
///
/// The order is [_IdreCompactLoaderState.lightingOrder]: outer left, outer right, inner left, inner right.
///
/// Use it in small places: inside buttons, cards, list items.
///
/// ```dart
/// const IdreCompactLoader(size: 24)
/// ```
class IdreCompactLoader extends StatefulWidget {
  const new({
    super.key,
    this.size = 48,
    this.color,
    this.loopDuration = const Duration(milliseconds: 1800),
    this.semanticLabel = 'Loading',
  });

  /// Side of the square, in logical pixels.
  final double size;

  /// Color of the loader. `null` = color of the surrounding `IconTheme`.
  final Color? color;

  /// Duration of one lighting cycle.
  final Duration loopDuration;

  /// Text read by screen readers.
  final String semanticLabel;

  @override
  State<IdreCompactLoader> createState() => _IdreCompactLoaderState();
}

class _IdreCompactLoaderState extends State<IdreCompactLoader> with SingleTickerProviderStateMixin {
  /// Order in which the tentacles light up, and then switch off.
  /// Change this list to change the cascade (e.g. a left-to-right sweep).
  static const List<IdreTentaclePosition> lightingOrder = [
    IdreTentaclePosition.outerLeft,
    IdreTentaclePosition.outerRight,
    IdreTentaclePosition.innerLeft,
    IdreTentaclePosition.innerRight,
  ];

  /// Opacity of a tentacle that is "off": still visible, so the shape of the logo never disappears.
  static const double unlitTentacleOpacity = 0.2;

  /// Timing of one cycle (fractions of [IdreCompactLoader.loopDuration]):
  /// - the first half lights the tentacles up, one every [delayBetweenTentacles];
  /// - the second half switches them off, in the same order;
  /// - each change (on or off) takes [transitionDuration].
  static const double switchOnPhaseStart = 0;
  static const double switchOffPhaseStart = 0.5;
  static const double delayBetweenTentacles = 0.11;
  static const double transitionDuration = 0.12;

  late final AnimationController _loopController = AnimationController(vsync: this, duration: widget.loopDuration)
    ..repeat();

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  /// How "on" the tentacle at position [orderIndex] in [lightingOrder] is (0.0 = off, 1.0 = on).
  static double _tentacleLightLevel(double loopProgress, int orderIndex) {
    final double tentacleDelay = orderIndex * delayBetweenTentacles;
    final double switchOnProgress = ((loopProgress - switchOnPhaseStart - tentacleDelay) / transitionDuration).clamp(
      0.0,
      1.0,
    );
    final double switchOffProgress = ((loopProgress - switchOffPhaseStart - tentacleDelay) / transitionDuration).clamp(
      0.0,
      1.0,
    );
    return switchOnProgress - switchOffProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: AnimatedBuilder(
        animation: _loopController,
        builder: (context, child) {
          final double loopProgress = _loopController.value;

          return IdreIcon(
            size: widget.size,
            foregroundColor: widget.color,
            semanticLabel: '',
            tentacleOpacityByPosition: {
              for (int orderIndex = 0; orderIndex < lightingOrder.length; orderIndex++)
                lightingOrder[orderIndex]:
                    unlitTentacleOpacity + (1 - unlitTentacleOpacity) * _tentacleLightLevel(loopProgress, orderIndex),
            },
          );
        },
      ),
    );
  }
}
