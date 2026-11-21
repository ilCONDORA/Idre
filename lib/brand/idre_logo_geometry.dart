import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:idre/brand/idre_tentacle_position.dart';
import 'package:idre/brand/idre_tentacle_role.dart';
import 'package:idre/brand/idre_tentacle_specification.dart';

/// The single source of truth for the shape of the Idre logo (the "i" with 4 tentacles).
///
/// ## Design units
/// Every number in this class is expressed in **design units** on a square canvas
/// of [designCanvasSize] × [designCanvasSize] (120 × 120). Painters scale these
/// values to the real size on screen, so the same geometry works for a 16 px
/// favicon and for a full-screen splash.
///
/// ## Anatomy
/// ```text
///          tip  ← tentacleTipDistanceFromHeadCenter
///         /
///        /  ← curved by a control point (tentacleControlPointDistanceFromHeadCenter)
///       /
///   start   ← tentacleStartDistanceFromHeadCenter (just outside the head)
///    (●)    ← head: headCenter + headRadius
///     ┃
///     ┃     ← stem: stemWidth, from stemTop to stemBottom
/// ```
///
/// ## Two variants
/// - [IdreLogoGeometry.standard]: for sizes from about 32 px upwards.
/// - [IdreLogoGeometry.smallSize]: thicker strokes and a wider fan, so the
///   tentacles stay readable at 16–24 px.
///
/// Use [IdreLogoGeometry.forRenderedSize] to pick the right one automatically.
@immutable
class IdreLogoGeometry {
  /// Geometry for medium and large sizes (about 32 px and above).
  const new standard()
    : headRadius = 10,
      stemWidth = 18,
      tentacleStrokeWidth = 5,
      tentacleTipDistanceFromHeadCenter = 34,
      tentacles = standardTentacles;

  /// Geometry for small sizes (favicon, system tray, notifications).
  ///
  /// Strokes are thicker and the tentacles are spread further apart,
  /// because thin details disappear below ~24 px.
  const new smallSize()
    : headRadius = 11,
      stemWidth = 20,
      tentacleStrokeWidth = 7,
      tentacleTipDistanceFromHeadCenter = 33,
      tentacles = smallSizeTentacles;

  /// Picks the geometry variant that reads best at [renderedLogicalSize]
  /// (the side of the square the logo will be drawn into, in logical pixels).
  factory forRenderedSize(double renderedLogicalSize) {
    if (renderedLogicalSize < smallSizeThresholdInLogicalPixels) {
      return const IdreLogoGeometry.smallSize();
    }
    return const IdreLogoGeometry.standard();
  }

  /// Below this rendered size (in logical pixels) the [IdreLogoGeometry.smallSize] variant is used.
  static const double smallSizeThresholdInLogicalPixels = 28;

  /// Side of the square design canvas. All other values are relative to it.
  static const double designCanvasSize = 120;

  /// Corner radius of the rounded square used as background in previews and in-app tiles.
  ///
  /// Real launcher icons get their shape from the operating system
  /// (Android adaptive icons, iOS/macOS squircle), so this is only used inside the app.
  static const double backgroundTileCornerRadius = 28;

  /// Center of the head (the dot of the "i").
  static const Offset headCenter = Offset(60, 52);

  /// Top edge of the stem (the body of the "i").
  static const double stemTop = 70;

  /// Bottom edge of the stem.
  static const double stemBottom = 106;

  /// Distance from [headCenter] where every tentacle starts (just outside the head).
  static const double tentacleStartDistanceFromHeadCenter = 14;

  /// Distance from [headCenter] of the control point that bends each tentacle.
  static const double tentacleControlPointDistanceFromHeadCenter = 24;

  /// How much the tip of a tentacle leans further out than its base angle.
  ///
  /// `1.0` would give a straight tentacle; `1.15` makes the tip flare outwards by 15 %,
  /// which gives the organic, "swaying" look.
  static const double tentacleTipFlareFactor = 1.15;

  /// Tentacles of the [IdreLogoGeometry.standard] variant, from left to right.
  ///
  /// Roles: the left-most tentacle is the server link; the other three bring the letters so that their
  /// arcs never cross — the tentacle that starts further left reaches the letter further right
  /// (inner left → "e", inner right → "r", outer right → "d").
  static const List<IdreTentacleSpecification> standardTentacles = [
    IdreTentacleSpecification(
      position: IdreTentaclePosition.outerLeft,
      role: IdreTentacleRole.serverLink,
      baseAngleInDegrees: -50,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.innerLeft,
      role: IdreTentacleRole.letterE,
      baseAngleInDegrees: -17,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.innerRight,
      role: IdreTentacleRole.letterR,
      baseAngleInDegrees: 17,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.outerRight,
      role: IdreTentacleRole.letterD,
      baseAngleInDegrees: 50,
    ),
  ];

  /// Tentacles of the [IdreLogoGeometry.smallSize] variant: same roles, wider fan.
  static const List<IdreTentacleSpecification> smallSizeTentacles = [
    IdreTentacleSpecification(
      position: IdreTentaclePosition.outerLeft,
      role: IdreTentacleRole.serverLink,
      baseAngleInDegrees: -56,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.innerLeft,
      role: IdreTentacleRole.letterE,
      baseAngleInDegrees: -20,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.innerRight,
      role: IdreTentacleRole.letterR,
      baseAngleInDegrees: 20,
    ),
    IdreTentacleSpecification(
      position: IdreTentaclePosition.outerRight,
      role: IdreTentacleRole.letterD,
      baseAngleInDegrees: 56,
    ),
  ];

  /// Radius of the head (the dot of the "i").
  final double headRadius;

  /// Width of the stem. Its corners are fully rounded (radius = width / 2).
  final double stemWidth;

  /// Stroke width of every tentacle.
  final double tentacleStrokeWidth;

  /// Distance from [headCenter] of the tip of every tentacle at rest.
  final double tentacleTipDistanceFromHeadCenter;

  /// The four tentacles, ordered from left to right.
  final List<IdreTentacleSpecification> tentacles;

  /// The stem as a rounded rectangle, centered horizontally under the head.
  RRect get stemRoundedRect {
    final Rect stemRect = Rect.fromLTRB(
      headCenter.dx - stemWidth / 2,
      stemTop,
      headCenter.dx + stemWidth / 2,
      stemBottom,
    );
    return RRect.fromRectAndRadius(stemRect, Radius.circular(stemWidth / 2));
  }

  /// Returns the tentacle in the given [position].
  IdreTentacleSpecification tentacleAt(IdreTentaclePosition position) {
    return tentacles.firstWhere((tentacle) => tentacle.position == position);
  }

  /// Returns the tentacle that has the given [role].
  IdreTentacleSpecification tentacleWithRole(IdreTentacleRole role) {
    return tentacles.firstWhere((tentacle) => tentacle.role == role);
  }

  /// Converts a direction ([angleFromVerticalInRadians], 0 = up, positive = right)
  /// and a [distanceFromHeadCenter] into a point on the design canvas.
  ///
  /// Screen coordinates grow downwards, which is why the vertical part is subtracted.
  Offset pointAroundHead({
    required double angleFromVerticalInRadians,
    required double distanceFromHeadCenter,
  }) {
    return Offset(
      headCenter.dx + distanceFromHeadCenter * math.sin(angleFromVerticalInRadians),
      headCenter.dy - distanceFromHeadCenter * math.cos(angleFromVerticalInRadians),
    );
  }

  /// Builds the path of [tentacle] in its resting position, as a quadratic Bézier curve:
  /// start (near the head) → control point (bends the curve) → tip (flared outwards).
  Path buildRestingTentaclePath(IdreTentacleSpecification tentacle) {
    final double baseAngle = tentacle.baseAngleInRadians;
    final double tipAngle = baseAngle * tentacleTipFlareFactor;

    final Offset startPoint = pointAroundHead(
      angleFromVerticalInRadians: baseAngle,
      distanceFromHeadCenter: tentacleStartDistanceFromHeadCenter,
    );
    final Offset controlPoint = pointAroundHead(
      angleFromVerticalInRadians: baseAngle,
      distanceFromHeadCenter: tentacleControlPointDistanceFromHeadCenter,
    );
    final Offset tipPoint = pointAroundHead(
      angleFromVerticalInRadians: tipAngle,
      distanceFromHeadCenter: tentacleTipDistanceFromHeadCenter,
    );

    return Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, tipPoint.dx, tipPoint.dy);
  }

  @override
  bool operator ==(Object other) {
    return other is IdreLogoGeometry &&
        other.headRadius == headRadius &&
        other.stemWidth == stemWidth &&
        other.tentacleStrokeWidth == tentacleStrokeWidth &&
        other.tentacleTipDistanceFromHeadCenter == tentacleTipDistanceFromHeadCenter &&
        listEquals(other.tentacles, tentacles);
  }

  @override
  int get hashCode => Object.hash(
    headRadius,
    stemWidth,
    tentacleStrokeWidth,
    tentacleTipDistanceFromHeadCenter,
    Object.hashAll(tentacles),
  );
}
