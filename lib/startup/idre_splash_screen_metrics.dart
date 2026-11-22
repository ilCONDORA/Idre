import 'dart:math' as math;
import 'dart:ui';

import 'package:idre/brand/idre_wordmark_geometry.dart';

/// Size of the animated splash on screen, shared by the Flutter splash and the native splash images.
///
/// The native splash screen (Android, iOS, web) is a fixed image that the operating system shows before
/// Flutter starts. To make the hand-off invisible, the Flutter splash must draw the "i" with exactly the
/// same size and in exactly the same place. Both sides use [designUnitInLogicalPixels]:
/// - here, to size the `IdreSplashAnimation`;
/// - in `tool/generate_native_splash_images.py`, which reads the value from this file.
///
/// ```text
/// screen center = center of IdreWordmarkGeometry.animatedDesignArea = where the "i" stands at the hand-off
/// 1 design unit = designUnitInLogicalPixels logical pixels (dp on Android, pt on iOS, CSS px on the web)
/// ```
abstract final class IdreSplashScreenMetrics {
  /// How many logical pixels one design unit of the wordmark measures in the splash screen.
  ///
  /// With 1.17 the smallest circle around the "i" (tentacles included, about 102 design units) is about
  /// 120 logical pixels wide, and the whole animated area is about 304 × 204: it fits a 360 dp wide phone.
  ///
  /// If you change it, run again `python3 tool/generate_native_splash_images.py` and
  /// `dart run flutter_native_splash:create`, otherwise the native image and the Flutter frame differ.
  static const double designUnitInLogicalPixels = 1.17;

  /// Largest part of the screen the splash may use when the screen is smaller than the splash.
  static const double maximumScreenFractionUsed = 0.9;

  /// Size of the animated splash for a screen (or window) of [screenSize].
  ///
  /// Normally this is the full size, so the "i" matches the native image. Only a window smaller than the
  /// splash (a narrow desktop or browser window) gets a smaller splash, so the wordmark always fits.
  static Size splashSizeFor(Size screenSize) {
    const Rect designArea = IdreWordmarkGeometry.animatedDesignArea;
    final double scaleThatFitsTheScreen = math.min(
      screenSize.width * maximumScreenFractionUsed / designArea.width,
      screenSize.height * maximumScreenFractionUsed / designArea.height,
    );
    final double designUnitSize = math.min(designUnitInLogicalPixels, scaleThatFitsTheScreen);
    return Size(designArea.width * designUnitSize, designArea.height * designUnitSize);
  }
}
