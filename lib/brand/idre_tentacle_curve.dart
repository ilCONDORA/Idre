import 'dart:ui';

/// Helpers for the paths used by tentacles.
abstract final class IdreTentacleCurve {
  /// Returns only the part of [path] between [fromFraction] and [toFraction] of its length
  /// (0.0 = start, 1.0 = end). Values outside 0–1 are clamped.
  ///
  /// This is how pulses are drawn: a short piece of the tentacle that moves along it.
  static Path extractSegment(Path path, {required double fromFraction, required double toFraction}) {
    final double clampedFromFraction = fromFraction.clamp(0.0, 1.0);
    final double clampedToFraction = toFraction.clamp(0.0, 1.0);
    final Path segmentPath = Path();
    if (clampedToFraction <= clampedFromFraction) {
      return segmentPath;
    }

    for (final PathMetric contour in path.computeMetrics()) {
      segmentPath.addPath(
        contour.extractPath(contour.length * clampedFromFraction, contour.length * clampedToFraction),
        Offset.zero,
      );
    }
    return segmentPath;
  }
}
