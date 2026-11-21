// Only the widgets layer is needed here: the logo does not use any Material widget.
import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_icon_painter.dart';
import 'package:idre/brand/idre_logo_geometry.dart';
import 'package:idre/brand/idre_tentacle_position.dart';

/// The static Idre logo as a widget: the "i" with its 4 tentacles.
///
/// ```dart
/// // Same color as the surrounding icons (IconTheme), no background tile.
/// const IdreIcon(size: 48)
///
/// // Follows the user's accent color.
/// IdreIcon(size: 48, foregroundColor: Theme.of(context).colorScheme.primary)
///
/// // Fixed brand colors with the rounded tile, like the launcher icon.
/// const IdreIcon(
///   size: 120,
///   foregroundColor: IdreBrandColors.logoColorOnDarkBackground,
///   backgroundColor: IdreBrandColors.darkBackground,
/// )
/// ```
///
/// The right geometry variant (standard or small-size) is picked automatically from [size].
class IdreIcon extends StatelessWidget {
  const new({
    super.key,
    required this.size,
    this.foregroundColor,
    this.backgroundColor,
    this.tentacleOpacityByPosition = const {},
    this.semanticLabel = 'Idre',
  });

  /// Side of the square the logo is drawn into, in logical pixels.
  final double size;

  /// Color of the logo.
  ///
  /// `null` = the color of the surrounding [IconTheme], exactly like the standard `Icon` widget,
  /// so the logo blends in with the other icons of an app bar or a button.
  final Color? foregroundColor;

  /// Color of the rounded tile behind the logo. `null` = no tile.
  final Color? backgroundColor;

  /// Opacity of single tentacles (0.0–1.0), used by loaders and status indicators.
  final Map<IdreTentaclePosition, double> tentacleOpacityByPosition;

  /// Text read by screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Color resolvedForegroundColor = foregroundColor ?? IconTheme.of(context).color ?? const Color(0xFF000000);

    return Semantics(
      label: semanticLabel,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(size),
          painter: IdreIconPainter(
            geometry: IdreLogoGeometry.forRenderedSize(size),
            foregroundColor: resolvedForegroundColor,
            backgroundColor: backgroundColor,
            tentacleOpacityByPosition: tentacleOpacityByPosition,
          ),
        ),
      ),
    );
  }
}
