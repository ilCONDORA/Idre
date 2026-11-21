import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:idre/brand/idre_logo_geometry.dart';
import 'package:idre/brand/idre_tentacle_position.dart';
import 'package:idre/brand/idre_tentacle_specification.dart';

/// Paints the static Idre logo: the "i" (head + stem) with its 4 tentacles.
///
/// ## How scaling works
/// The geometry lives on a 120 × 120 design canvas ([IdreLogoGeometry.designCanvasSize]).
/// This painter:
/// 1. finds the largest square that fits in the available size;
/// 2. moves the canvas origin to the top-left corner of that square (centering it);
/// 3. scales the canvas, so that 120 design units = the side of the square.
///
/// After step 3 we can draw using the design values directly, without converting
/// every single coordinate by hand.
///
/// ## Dimming tentacles
/// [tentacleOpacityByPosition] lets callers dim single tentacles (0.0 = invisible,
/// 1.0 = fully visible). The loaders and the server status indicator are built on this:
/// for example, "2 tentacles lit" = the inner pair at 1.0 and the outer pair at 0.25.
class IdreIconPainter extends CustomPainter {
  const new({
    required this.geometry,
    required this.foregroundColor,
    this.backgroundColor,
    this.tentacleOpacityByPosition = const {},
  });

  /// Shape of the logo (standard or small-size variant).
  final IdreLogoGeometry geometry;

  /// Color of the "i" and of the tentacles.
  final Color foregroundColor;

  /// Color of the rounded-square tile behind the logo. `null` = transparent (no tile).
  final Color? backgroundColor;

  /// Opacity of each tentacle, from 0.0 to 1.0. Missing positions are fully visible.
  final Map<IdreTentaclePosition, double> tentacleOpacityByPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final double squareSide = size.shortestSide;
    final double scaleFromDesignToScreen = squareSide / IdreLogoGeometry.designCanvasSize;
    final Offset squareTopLeft = Offset(
      (size.width - squareSide) / 2,
      (size.height - squareSide) / 2,
    );

    canvas.save();
    canvas.translate(squareTopLeft.dx, squareTopLeft.dy);
    canvas.scale(scaleFromDesignToScreen);

    _paintBackgroundTile(canvas);
    _paintBody(canvas);
    _paintTentacles(canvas);

    canvas.restore();
  }

  /// Draws the optional rounded-square tile behind the logo.
  void _paintBackgroundTile(Canvas canvas) {
    final Color? tileColor = backgroundColor;
    if (tileColor == null) {
      return;
    }

    final RRect tileRoundedRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, IdreLogoGeometry.designCanvasSize, IdreLogoGeometry.designCanvasSize),
      const Radius.circular(IdreLogoGeometry.backgroundTileCornerRadius),
    );
    canvas.drawRRect(tileRoundedRect, Paint()..color = tileColor);
  }

  /// Draws the "i" itself: the stem (body) and the dot (head).
  void _paintBody(Canvas canvas) {
    final Paint bodyFillPaint = Paint()
      ..color = foregroundColor
      ..isAntiAlias = true;

    canvas.drawRRect(geometry.stemRoundedRect, bodyFillPaint);
    canvas.drawCircle(IdreLogoGeometry.headCenter, geometry.headRadius, bodyFillPaint);
  }

  /// Draws each tentacle as a stroked curve with round ends.
  void _paintTentacles(Canvas canvas) {
    for (final IdreTentacleSpecification tentacle in geometry.tentacles) {
      final double tentacleOpacity = (tentacleOpacityByPosition[tentacle.position] ?? 1.0).clamp(0.0, 1.0);
      if (tentacleOpacity == 0) {
        continue;
      }

      final Paint tentacleStrokePaint = Paint()
        ..color = foregroundColor.withValues(alpha: foregroundColor.a * tentacleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.tentacleStrokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawPath(geometry.buildRestingTentaclePath(tentacle), tentacleStrokePaint);
    }
  }

  /// Repaint only when something that changes the drawing has changed.
  @override
  bool shouldRepaint(IdreIconPainter oldDelegate) {
    return oldDelegate.geometry != geometry ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        !mapEquals(oldDelegate.tentacleOpacityByPosition, tentacleOpacityByPosition);
  }
}
