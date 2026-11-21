import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:idre/brand/idre_tentacle_position.dart';
import 'package:idre/brand/idre_tentacle_role.dart';

/// Describes one tentacle of the Idre logo: where it is, what it does
/// and in which direction it points when the logo is at rest.
///
/// The direction is an angle measured **from the vertical**, in degrees:
/// - `0` means "straight up";
/// - negative values lean to the left (e.g. `-50`);
/// - positive values lean to the right (e.g. `50`).
///
/// Using degrees here (instead of radians) keeps the values easy to read
/// and tweak by hand; [baseAngleInRadians] converts them for the math.
@immutable
class IdreTentacleSpecification {
  const new({
    required this.position,
    required this.role,
    required this.baseAngleInDegrees,
  });

  /// Where the tentacle sits on the head (outer/inner, left/right).
  final IdreTentaclePosition position;

  /// What the tentacle does in the animated logo (server link or a letter).
  final IdreTentacleRole role;

  /// Direction of the tentacle at rest, in degrees from the vertical.
  final double baseAngleInDegrees;

  /// Same as [baseAngleInDegrees], converted to radians for `sin` / `cos`.
  double get baseAngleInRadians => baseAngleInDegrees * math.pi / 180;

  @override
  bool operator ==(Object other) {
    return other is IdreTentacleSpecification &&
        other.position == position &&
        other.role == role &&
        other.baseAngleInDegrees == baseAngleInDegrees;
  }

  @override
  int get hashCode => Object.hash(position, role, baseAngleInDegrees);
}
