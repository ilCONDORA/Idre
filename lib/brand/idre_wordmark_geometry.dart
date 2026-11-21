import 'dart:math' as math;
import 'dart:ui';

import 'package:idre/brand/idre_logo_geometry.dart';
import 'package:idre/brand/idre_tentacle_curve_points.dart';
import 'package:idre/brand/idre_tentacle_role.dart';
import 'package:idre/brand/idre_tentacle_specification.dart';

/// The single source of truth for the shape of the "idre" wordmark (the logo with its letters).
///
/// Like [IdreLogoGeometry], every value is in **design units**; painters scale them to the real
/// size with [applyFitTransform].
///
/// - The letters are **monoline** paths (one stroke, round ends), so they can be animated.
/// - Each letter has an **anchor point**: where its tentacle grabs it in the splash screen and
///   where the pulse arrives in the pulse loader.
/// - The letters are identified by the tentacle role that brings them ([IdreTentacleRole.letterD],
///   [IdreTentacleRole.letterR], [IdreTentacleRole.letterE]).
///
/// ## Two design areas
/// - [staticDesignArea]: tight around the wordmark at rest (app bar, about page).
/// - [animatedDesignArea]: taller, because the stretched tentacles arc high above the letters.
///
/// ## Connected tentacles
/// A tentacle stretched towards a letter leaves the head **from its own resting position and
/// direction**, arcs over the letters and lands on the anchor from above. The three arcs are nested
/// ("d" lowest, "e" highest) so they never cross each other or touch a letter.
abstract final class IdreWordmarkGeometry {
  /// Area around the wordmark at rest: everything visible in the final logo, plus a small margin.
  static const Rect staticDesignArea = Rect.fromLTRB(10, 30, 254, 140);

  /// Area used by the splash screen and the pulse loader: extends above the letters (negative y)
  /// to make room for the arcs of the stretched tentacles.
  static const Rect animatedDesignArea = Rect.fromLTRB(0, -24, 260, 150);

  /// Stroke width of the letters and of the stem of the "i".
  static const double letterStrokeWidth = 12;

  /// Stroke width of every tentacle (resting, stretched or connected).
  static const double tentacleStrokeWidth = 5;

  /// Center of the head (dot of the "i") in the final wordmark.
  static const Offset headCenter = Offset(40, 62);

  /// Radius of the head.
  static const double headRadius = 9;

  /// Horizontal position of the stem of the "i".
  static const double stemCenterX = 40;

  /// Top of the lowercase letters (x-height line) and of the stem of the "i".
  static const double xHeightLineY = 86;

  /// Bottom of all the letters.
  static const double baselineY = 130;

  /// Distances from the head center of a resting tentacle: start (just outside the head),
  /// control point (bends the curve) and tip.
  static const double restingTentacleStartDistance = 12;
  static const double restingTentacleControlPointDistance = 19;
  static const double restingTentacleTipDistance = 27;

  /// The three letters after the "i", in reading order.
  static const List<IdreTentacleRole> letterRoles = [
    IdreTentacleRole.letterD,
    IdreTentacleRole.letterR,
    IdreTentacleRole.letterE,
  ];

  /// How far a connected tentacle keeps going in its own resting direction before bending
  /// towards the letter (length of the first control point). Longer = higher, rounder arc.
  static const Map<IdreTentacleRole, double> connectedTentacleDepartureLength = {
    IdreTentacleRole.letterD: 30,
    IdreTentacleRole.letterR: 85,
    IdreTentacleRole.letterE: 130,
  };

  /// Position of the second control point relative to the anchor: the direction the tentacle
  /// comes from when it lands on the letter (here: from above, slightly from the left).
  ///
  /// These values (and [connectedTentacleDepartureLength]) were found with a script that
  /// checks that the arcs keep at least 12.5 design units from each other and from the letters.
  static const Map<IdreTentacleRole, Offset> connectedTentacleLandingOffset = {
    IdreTentacleRole.letterD: Offset(-18, -28),
    IdreTentacleRole.letterR: Offset(-10, -80),
    IdreTentacleRole.letterE: Offset(-40, -90),
  };

  /// Scales and centers [canvas] so that [designArea] fits inside [availableSize].
  ///
  /// Call it after `canvas.save()` and before drawing with design units.
  static void applyFitTransform(Canvas canvas, Size availableSize, Rect designArea) {
    final double scaleFromDesignToScreen = math.min(
      availableSize.width / designArea.width,
      availableSize.height / designArea.height,
    );
    canvas.translate(
      (availableSize.width - designArea.width * scaleFromDesignToScreen) / 2,
      (availableSize.height - designArea.height * scaleFromDesignToScreen) / 2,
    );
    canvas.scale(scaleFromDesignToScreen);
    canvas.translate(-designArea.left, -designArea.top);
  }

  /// The tentacle (from the app icon geometry) that has the given [role].
  static IdreTentacleSpecification tentacleWithRole(IdreTentacleRole role) {
    return IdreLogoGeometry.standardTentacles.firstWhere(
      (tentacle) => tentacle.role == role,
    );
  }

  /// The stem (body) of the "i", as a vertical line.
  static Path buildStemPath() {
    return Path()
      ..moveTo(stemCenterX, xHeightLineY)
      ..lineTo(stemCenterX, baselineY);
  }

  /// The monoline path of the letter brought by [letterRole].
  static Path buildLetterPath(IdreTentacleRole letterRole) {
    switch (letterRole) {
      case IdreTentacleRole.letterD:
        return Path()
          // Ascender (the tall line of the "d").
          ..moveTo(117, 44)
          ..lineTo(117, baselineY)
          // Bowl (the round part).
          ..addOval(Rect.fromCircle(center: const Offset(95, 108), radius: 22));
      case IdreTentacleRole.letterR:
        return Path()
          // Stem.
          ..moveTo(147, xHeightLineY)
          ..lineTo(147, baselineY)
          // Arm (the small curve on the right).
          ..moveTo(147, 104)
          ..cubicTo(151, 90, 162, 85, 176, 88);
      case IdreTentacleRole.letterE:
        return Path()
          // Horizontal bar, from left to right…
          ..moveTo(200, 108)
          ..lineTo(244, 108)
          // …then the round body, going up and around, ending at the bottom right.
          ..arcToPoint(const Offset(237.6, 123.6), radius: const Radius.circular(22), largeArc: true, clockwise: false);
      case IdreTentacleRole.serverLink:
        throw ArgumentError.value(letterRole, 'letterRole', 'The server link tentacle has no letter');
    }
  }

  /// Where the tentacle grabs the letter: top of the "d", top of the "r", top of the "e".
  static Offset anchorPointOf(IdreTentacleRole letterRole) {
    switch (letterRole) {
      case IdreTentacleRole.letterD:
        return const Offset(117, 44);
      case IdreTentacleRole.letterR:
        return const Offset(147, xHeightLineY);
      case IdreTentacleRole.letterE:
        return const Offset(222, xHeightLineY);
      case IdreTentacleRole.serverLink:
        throw ArgumentError.value(letterRole, 'letterRole', 'The server link tentacle has no letter');
    }
  }

  /// Shape of [tentacle] at rest, around a head placed at [currentHeadCenter]
  /// (same angles as the app icon, sized for the wordmark).
  static IdreTentacleCurvePoints restingTentacleCurvePoints(
    IdreTentacleSpecification tentacle, {
    Offset currentHeadCenter = headCenter,
  }) {
    final double baseAngle = tentacle.baseAngleInRadians;
    final double tipAngle = baseAngle * IdreLogoGeometry.tentacleTipFlareFactor;

    return IdreTentacleCurvePoints.fromQuadratic(
      start: _pointAroundHead(currentHeadCenter, baseAngle, restingTentacleStartDistance),
      control: _pointAroundHead(currentHeadCenter, baseAngle, restingTentacleControlPointDistance),
      end: _pointAroundHead(currentHeadCenter, tipAngle, restingTentacleTipDistance),
    );
  }

  /// Shape of [tentacle] stretched from the head to its letter.
  ///
  /// [anchorPoint] defaults to the letter's final anchor; the splash passes the anchor of a letter
  /// that is still moving. The start is the same as the resting shape, so the two can be morphed.
  static IdreTentacleCurvePoints connectedTentacleCurvePoints(
    IdreTentacleSpecification tentacle, {
    Offset? anchorPoint,
    Offset currentHeadCenter = headCenter,
  }) {
    final double baseAngle = tentacle.baseAngleInRadians;
    final Offset resolvedAnchorPoint = anchorPoint ?? anchorPointOf(tentacle.role);
    final Offset startPoint = _pointAroundHead(currentHeadCenter, baseAngle, restingTentacleStartDistance);
    final Offset departureDirection = Offset(math.sin(baseAngle), -math.cos(baseAngle));

    return IdreTentacleCurvePoints(
      start: startPoint,
      firstControl: startPoint + departureDirection * connectedTentacleDepartureLength[tentacle.role]!,
      secondControl: resolvedAnchorPoint + connectedTentacleLandingOffset[tentacle.role]!,
      end: resolvedAnchorPoint,
    );
  }

  /// Path of [tentacle] at rest.
  static Path buildRestingTentaclePath(IdreTentacleSpecification tentacle, {Offset currentHeadCenter = headCenter}) {
    return restingTentacleCurvePoints(tentacle, currentHeadCenter: currentHeadCenter).toPath();
  }

  /// Converts a direction (radians from the vertical, positive = right) and a distance into a point.
  static Offset _pointAroundHead(Offset currentHeadCenter, double angleFromVertical, double distance) {
    return Offset(
      currentHeadCenter.dx + distance * math.sin(angleFromVertical),
      currentHeadCenter.dy - distance * math.cos(angleFromVertical),
    );
  }
}
