import 'package:flutter/foundation.dart';

/// Tells whether the operating system shows a native splash screen before Flutter starts.
///
/// `flutter_native_splash` generates one for Android, iOS and the web, showing the "i" at rest in the center
/// (see `flutter_native_splash.yaml`). Desktop has none: Windows and Linux show the window only after Flutter
/// has drawn its first frame, so there the splash plays its full choreography, pop-in included.
abstract final class IdreNativeSplashPlatforms {
  /// `true` on Android, iOS and the web.
  static bool get isNativeSplashShownBeforeFlutter {
    if (kIsWeb) {
      return true;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia || TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows => false,
    };
  }
}
