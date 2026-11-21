import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_wordmark_geometry.dart';
import 'package:idre/brand/idre_wordmark_painter.dart';

/// The static "idre" wordmark (logo + letters), e.g. for an app bar or an "about" page.
///
/// It is exactly the last frame of the splash animation, painted by the same painter,
/// so the splash always ends on the real logo.
class IdreWordmark extends StatelessWidget {
  const new({super.key, required this.height, this.color, this.semanticLabel = 'Idre'});

  /// Height of the wordmark in logical pixels; the width follows the design proportions.
  final double height;

  /// Color of the wordmark. `null` = color of the surrounding `IconTheme`.
  final Color? color;

  /// Text read by screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    const Rect designArea = IdreWordmarkGeometry.staticDesignArea;
    final double width = height * designArea.width / designArea.height;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, height),
          painter: IdreWordmarkPainter(
            color: color ?? IconTheme.of(context).color ?? const Color(0xFF000000),
            assemblyProgress: const AlwaysStoppedAnimation<double>(1),
            designArea: designArea,
          ),
        ),
      ),
    );
  }
}
