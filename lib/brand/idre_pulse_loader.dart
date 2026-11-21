import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_pulse_loader_painter.dart';
import 'package:idre/brand/idre_wordmark_geometry.dart';

/// Large loader: the full wordmark with pulses running from the server into Idre and out to the letters.
///
/// Use it where there is space: first library load, connecting to the server, full-page states.
///
/// ```dart
/// const IdrePulseLoader(height: 64)
/// ```
class IdrePulseLoader extends StatefulWidget {
  const new({
    super.key,
    required this.height,
    this.color,
    this.loopDuration = const Duration(milliseconds: 1800),
    this.semanticLabel = 'Loading',
  });

  /// Height in logical pixels; the width follows the wordmark proportions.
  final double height;

  /// Color of the loader. `null` = color of the surrounding `IconTheme`.
  final Color? color;

  /// Duration of one loop (incoming pulse + three outgoing pulses).
  final Duration loopDuration;

  /// Text read by screen readers.
  final String semanticLabel;

  @override
  State<IdrePulseLoader> createState() => _IdrePulseLoaderState();
}

class _IdrePulseLoaderState extends State<IdrePulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _loopController = AnimationController(vsync: this, duration: widget.loopDuration)
    ..repeat();

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Rect designArea = IdreWordmarkGeometry.animatedDesignArea;
    final double width = widget.height * designArea.width / designArea.height;

    return Semantics(
      label: widget.semanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, widget.height),
          painter: IdrePulseLoaderPainter(
            color: widget.color ?? IconTheme.of(context).color ?? const Color(0xFF000000),
            loopProgress: _loopController,
          ),
        ),
      ),
    );
  }
}
