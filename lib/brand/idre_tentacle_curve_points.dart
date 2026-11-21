import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The 4 points of a cubic Bézier curve that describes the shape of a tentacle.
///
/// ```text
///          firstControl ●            ● secondControl
///                      ╱  ╭────────╮  ╲
///                     ╱ ╭╯          ╰╮ ╲
///             start ●──╯              ╰──● end
/// ```
///
/// - [start] and [end] are where the tentacle begins (on the head) and finishes;
/// - the two control points "pull" the curve: the tentacle leaves [start] heading towards
///   [firstControl] and arrives at [end] coming from [secondControl].
///
/// Every tentacle shape (resting, stretched towards a letter) uses the same 4-point format,
/// so one shape can be **morphed** smoothly into another with [lerp]: this is how a tentacle
/// stretches out of its resting position and goes back into it.
@immutable
class IdreTentacleCurvePoints {
  const new({
    required this.start,
    required this.firstControl,
    required this.secondControl,
    required this.end,
  });

  /// Converts a quadratic curve (1 control point) into the equivalent cubic curve (2 control points).
  ///
  /// The drawn shape is identical; we only need the 4-point format to morph it into other shapes.
  /// Formula: each cubic control point is 2/3 of the way from its end point to the quadratic control point.
  factory fromQuadratic({
    required Offset start,
    required Offset control,
    required Offset end,
  }) {
    return IdreTentacleCurvePoints(
      start: start,
      firstControl: start + (control - start) * (2 / 3),
      secondControl: end + (control - end) * (2 / 3),
      end: end,
    );
  }

  final Offset start;
  final Offset firstControl;
  final Offset secondControl;
  final Offset end;

  /// Blends shape [from] into shape [to]: `progress` 0.0 = [from], 1.0 = [to], 0.5 = halfway.
  static IdreTentacleCurvePoints lerp(IdreTentacleCurvePoints from, IdreTentacleCurvePoints to, double progress) {
    return IdreTentacleCurvePoints(
      start: Offset.lerp(from.start, to.start, progress)!,
      firstControl: Offset.lerp(from.firstControl, to.firstControl, progress)!,
      secondControl: Offset.lerp(from.secondControl, to.secondControl, progress)!,
      end: Offset.lerp(from.end, to.end, progress)!,
    );
  }

  /// Moves only the control points, leaving both ends in place: used for the "swimming" wave.
  IdreTentacleCurvePoints withNudgedControls({required Offset firstControlNudge, required Offset secondControlNudge}) {
    return IdreTentacleCurvePoints(
      start: start,
      firstControl: firstControl + firstControlNudge,
      secondControl: secondControl + secondControlNudge,
      end: end,
    );
  }

  /// The drawable path of this shape.
  Path toPath() {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(firstControl.dx, firstControl.dy, secondControl.dx, secondControl.dy, end.dx, end.dy);
  }
}
