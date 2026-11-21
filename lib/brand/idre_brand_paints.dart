import 'dart:ui';

/// Ready-made [Paint] objects for the brand drawings, so every painter draws strokes the same way.
abstract final class IdreBrandPaints {
  /// A stroke with round ends and joins (letters and tentacles).
  ///
  /// [opacity] (0.0–1.0) is multiplied with the alpha of [color].
  static Paint roundStroke({required Color color, required double width, double opacity = 1}) {
    return Paint()
      ..color = color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
  }

  /// A solid fill (the head of the "i").
  static Paint fill({required Color color, double opacity = 1}) {
    return Paint()
      ..color = color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0))
      ..isAntiAlias = true;
  }
}
