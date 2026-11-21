import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'package:idre/brand/idre_brand_paints.dart';
import 'package:idre/brand/idre_logo_geometry.dart';
import 'package:idre/brand/idre_splash_timeline.dart';
import 'package:idre/brand/idre_tentacle_curve_points.dart';
import 'package:idre/brand/idre_tentacle_role.dart';
import 'package:idre/brand/idre_tentacle_specification.dart';
import 'package:idre/brand/idre_wordmark_geometry.dart';

/// Paints the "idre" wordmark at any moment of the splash animation.
///
/// [assemblyProgress] goes from 0.0 (nothing on screen) to 1.0 (the complete, static wordmark):
/// - the splash screen passes its `AnimationController`;
/// - the static wordmark passes `AlwaysStoppedAnimation(1.0)`.
///
/// ## How a tentacle brings its letter
/// Every tentacle always has a shape made of 4 points ([IdreTentacleCurvePoints]):
/// 1. **shoot**: its resting shape morphs into the shape stretched towards the (still far) letter;
/// 2. **pull**: the letter moves to its place and the tentacle follows it, "swimming" a little;
/// 3. **retract**: the stretched shape morphs back into the resting shape.
///
/// Each tentacle starts and ends in its own resting position, so the final frame is the logo at rest.
///
/// The animation is given to `super(repaint: ...)`: Flutter then repaints on every tick
/// **without rebuilding any widget**, which is the cheapest way to animate a `CustomPainter`.
class IdreWordmarkPainter extends CustomPainter {
  new({
    required this.color,
    required this.assemblyProgress,
    this.designArea = IdreWordmarkGeometry.animatedDesignArea,
  }) : super(repaint: assemblyProgress);

  /// Color of the whole wordmark.
  final Color color;

  /// Progress of the splash animation, 0.0 → 1.0.
  final Animation<double> assemblyProgress;

  /// Part of the design canvas fitted into the widget: the tall animated area for the splash,
  /// the tight static area for the static wordmark.
  final Rect designArea;

  /// Horizontal distance (design units) between the center of the animated area, where the "i"
  /// appears, and its final position in the wordmark.
  static final double iStartOffsetX =
      IdreWordmarkGeometry.animatedDesignArea.center.dx - IdreWordmarkGeometry.stemCenterX;

  /// Where each letter comes from, relative to its final position (design units):
  /// "d" from the top, "r" from the bottom, "e" from the right.
  static const Map<IdreTentacleRole, Offset> letterStartOffsets = {
    IdreTentacleRole.letterD: Offset(30, -130),
    IdreTentacleRole.letterR: Offset(20, 120),
    IdreTentacleRole.letterE: Offset(150, -10),
  };

  /// Strength (design units) of the "swimming" wave of a tentacle while it carries its letter.
  static const double tentacleWaveAmplitude = 5;

  /// Point on the "i" around which it scales while popping in (middle of the stem).
  static const Offset iPopPivot = Offset(IdreWordmarkGeometry.stemCenterX, 108);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = assemblyProgress.value;
    final double headPopScale = IdreSplashTimeline.headPopScale(t);
    if (headPopScale <= 0) {
      return;
    }

    canvas.save();
    IdreWordmarkGeometry.applyFitTransform(canvas, size, designArea);

    final double iOffsetX = lerpDouble(iStartOffsetX, 0, IdreSplashTimeline.slideProgress(t))!;
    final Offset currentHeadCenter = IdreWordmarkGeometry.headCenter + Offset(iOffsetX, 0);

    for (int letterIndex = 0; letterIndex < IdreWordmarkGeometry.letterRoles.length; letterIndex++) {
      _paintLetterWithItsStretchedTentacle(canvas, t, letterIndex, currentHeadCenter);
    }
    _paintTheI(canvas, t, iOffsetX, headPopScale);

    canvas.restore();
  }

  /// Draws one letter (d, r or e) and, while it is being brought in, the stretched tentacle holding it.
  void _paintLetterWithItsStretchedTentacle(Canvas canvas, double t, int letterIndex, Offset currentHeadCenter) {
    final double shootProgress = IdreSplashTimeline.shootProgress(t, letterIndex);
    if (shootProgress == 0) {
      // The letter has not been called yet; its tentacle is at rest (drawn with the "i").
      return;
    }
    final IdreTentacleRole letterRole = IdreWordmarkGeometry.letterRoles[letterIndex];
    final double pullProgress = IdreSplashTimeline.pullProgress(t, letterIndex);
    final double retractProgress = IdreSplashTimeline.retractProgress(t, letterIndex);

    // Where the letter is now: far away at the start, at its place at the end (with a small overshoot).
    final Offset currentLetterOffset =
        letterStartOffsets[letterRole]! * (1 - Curves.easeOutBack.transform(pullProgress));

    canvas.save();
    canvas.translate(currentLetterOffset.dx, currentLetterOffset.dy);
    canvas.drawPath(
      IdreWordmarkGeometry.buildLetterPath(letterRole),
      IdreBrandPaints.roundStroke(
        color: color,
        width: IdreWordmarkGeometry.letterStrokeWidth,
        opacity: math.min(1, shootProgress * 2),
      ),
    );
    canvas.restore();

    if (!IdreSplashTimeline.isTentacleStretched(t, letterIndex)) {
      return;
    }

    final IdreTentacleSpecification tentacle = IdreWordmarkGeometry.tentacleWithRole(letterRole);
    final IdreTentacleCurvePoints restingShape = IdreWordmarkGeometry.restingTentacleCurvePoints(
      tentacle,
      currentHeadCenter: currentHeadCenter,
    );
    final IdreTentacleCurvePoints stretchedShape = IdreWordmarkGeometry.connectedTentacleCurvePoints(
      tentacle,
      anchorPoint: IdreWordmarkGeometry.anchorPointOf(letterRole) + currentLetterOffset,
      currentHeadCenter: currentHeadCenter,
    );

    // A small wave that fades out as the letter settles.
    final double waveOffset = math.sin(t * 40 + letterIndex * 1.7) * tentacleWaveAmplitude * (1 - pullProgress);
    final IdreTentacleCurvePoints wavingStretchedShape = stretchedShape.withNudgedControls(
      firstControlNudge: Offset(0, waveOffset),
      secondControlNudge: Offset(0, -waveOffset),
    );

    final IdreTentacleCurvePoints currentShape = shootProgress < 1
        ? IdreTentacleCurvePoints.lerp(restingShape, wavingStretchedShape, Curves.easeOutCubic.transform(shootProgress))
        : IdreTentacleCurvePoints.lerp(
            wavingStretchedShape,
            restingShape,
            Curves.easeInOutCubic.transform(retractProgress),
          );

    canvas.drawPath(
      currentShape.toPath(),
      IdreBrandPaints.roundStroke(color: color, width: IdreWordmarkGeometry.tentacleStrokeWidth),
    );
  }

  /// Draws the "i": its resting tentacles (except the stretched ones), stem and head,
  /// scaled while it pops in.
  void _paintTheI(Canvas canvas, double t, double iOffsetX, double headPopScale) {
    canvas.save();
    canvas.translate(iOffsetX, 0);
    canvas.translate(iPopPivot.dx, iPopPivot.dy);
    canvas.scale(headPopScale);
    canvas.translate(-iPopPivot.dx, -iPopPivot.dy);

    final Paint tentaclePaint = IdreBrandPaints.roundStroke(
      color: color,
      width: IdreWordmarkGeometry.tentacleStrokeWidth,
    );
    for (final IdreTentacleSpecification tentacle in IdreLogoGeometry.standardTentacles) {
      final int letterIndex = IdreWordmarkGeometry.letterRoles.indexOf(tentacle.role);
      final bool isServerLink = letterIndex == -1;
      if (!isServerLink && IdreSplashTimeline.isTentacleStretched(t, letterIndex)) {
        continue;
      }
      canvas.drawPath(IdreWordmarkGeometry.buildRestingTentaclePath(tentacle), tentaclePaint);
    }

    canvas.drawPath(
      IdreWordmarkGeometry.buildStemPath(),
      IdreBrandPaints.roundStroke(color: color, width: IdreWordmarkGeometry.letterStrokeWidth),
    );
    canvas.drawCircle(
      IdreWordmarkGeometry.headCenter,
      IdreWordmarkGeometry.headRadius,
      IdreBrandPaints.fill(color: color),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(IdreWordmarkPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.assemblyProgress != assemblyProgress ||
        oldDelegate.designArea != designArea;
  }
}
