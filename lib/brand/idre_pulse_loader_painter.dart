import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'package:idre/brand/idre_brand_paints.dart';
import 'package:idre/brand/idre_tentacle_curve.dart';
import 'package:idre/brand/idre_tentacle_role.dart';
import 'package:idre/brand/idre_tentacle_specification.dart';
import 'package:idre/brand/idre_wordmark_geometry.dart';

/// Paints the pulse loader: the complete wordmark with the "i" connected to every letter by a
/// tentacle, and light pulses travelling along the tentacles.
///
/// The story it tells is the real path of the data:
/// 1. a pulse **enters** through the server-link tentacle (from the Jellyfin server into Idre);
/// 2. three pulses **leave** the head towards "d", "r" and "e" (from Idre to the screen).
///
/// [loopProgress] goes from 0.0 to 1.0 and repeats.
class IdrePulseLoaderPainter extends CustomPainter {
  new({required this.color, required this.loopProgress}) : super(repaint: loopProgress);

  final Color color;

  /// Progress of one loop, 0.0 → 1.0, repeated by the widget.
  final Animation<double> loopProgress;

  /// Opacity of the tentacles under the pulses, so the "cables" are always visible.
  static const double idleTentacleOpacity = 0.3;

  /// Length of a pulse, as a fraction of the tentacle length.
  static const double pulseLengthFraction = 0.35;

  /// Loop windows: the incoming pulse first, then the three outgoing pulses, slightly staggered.
  static const double incomingPulseStart = 0;
  static const double incomingPulseDuration = 0.3;
  static const double firstOutgoingPulseStart = 0.3;
  static const double delayBetweenOutgoingPulses = 0.08;
  static const double outgoingPulseDuration = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = loopProgress.value;

    canvas.save();
    IdreWordmarkGeometry.applyFitTransform(canvas, size, IdreWordmarkGeometry.animatedDesignArea);

    final Paint idleTentaclePaint = IdreBrandPaints.roundStroke(
      color: color,
      width: IdreWordmarkGeometry.tentacleStrokeWidth,
      opacity: idleTentacleOpacity,
    );
    final Paint pulsePaint = IdreBrandPaints.roundStroke(color: color, width: IdreWordmarkGeometry.tentacleStrokeWidth);

    // 1. Incoming pulse on the server-link tentacle: it travels from the tip (1.0) to the head (0.0).
    final Path serverLinkTentaclePath = IdreWordmarkGeometry.buildRestingTentaclePath(
      IdreWordmarkGeometry.tentacleWithRole(IdreTentacleRole.serverLink),
    );
    canvas.drawPath(serverLinkTentaclePath, idleTentaclePaint);
    final double incomingProgress = _windowProgress(t, incomingPulseStart, incomingPulseDuration);
    if (incomingProgress > 0 && incomingProgress < 1) {
      final double pulseHead = 1 - incomingProgress * (1 + pulseLengthFraction);
      canvas.drawPath(
        IdreTentacleCurve.extractSegment(
          serverLinkTentaclePath,
          fromFraction: pulseHead,
          toFraction: pulseHead + pulseLengthFraction,
        ),
        pulsePaint,
      );
    }

    // 2. Outgoing pulses on the three letter tentacles: from the head (0.0) to the letter (1.0).
    for (int letterIndex = 0; letterIndex < IdreWordmarkGeometry.letterRoles.length; letterIndex++) {
      final IdreTentacleRole letterRole = IdreWordmarkGeometry.letterRoles[letterIndex];
      // Each tentacle leaves the head from its own resting position and arcs over to its letter.
      final IdreTentacleSpecification tentacle = IdreWordmarkGeometry.tentacleWithRole(letterRole);
      final Path connectedTentaclePath = IdreWordmarkGeometry.connectedTentacleCurvePoints(tentacle).toPath();
      canvas.drawPath(connectedTentaclePath, idleTentaclePaint);

      final double outgoingProgress = _windowProgress(
        t,
        firstOutgoingPulseStart + letterIndex * delayBetweenOutgoingPulses,
        outgoingPulseDuration,
      );
      if (outgoingProgress > 0 && outgoingProgress < 1) {
        final double pulseFront = Curves.easeInOut.transform(outgoingProgress) * (1 + pulseLengthFraction);
        canvas.drawPath(
          IdreTentacleCurve.extractSegment(
            connectedTentaclePath,
            fromFraction: pulseFront - pulseLengthFraction,
            toFraction: pulseFront,
          ),
          pulsePaint,
        );
      }
    }

    // 3. The wordmark itself, drawn last so it covers the start of every tentacle.
    final Paint letterPaint = IdreBrandPaints.roundStroke(color: color, width: IdreWordmarkGeometry.letterStrokeWidth);
    for (final IdreTentacleRole letterRole in IdreWordmarkGeometry.letterRoles) {
      canvas.drawPath(IdreWordmarkGeometry.buildLetterPath(letterRole), letterPaint);
    }
    canvas.drawPath(IdreWordmarkGeometry.buildStemPath(), letterPaint);
    canvas.drawCircle(
      IdreWordmarkGeometry.headCenter,
      IdreWordmarkGeometry.headRadius,
      IdreBrandPaints.fill(color: color),
    );

    canvas.restore();
  }

  /// Local progress (0.0–1.0) of a window of the loop.
  static double _windowProgress(double t, double windowStart, double windowDuration) {
    return ((t - windowStart) / windowDuration).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(IdrePulseLoaderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.loopProgress != loopProgress;
  }
}
