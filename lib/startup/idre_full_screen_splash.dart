import 'package:flutter/widgets.dart';

import 'package:idre/brand/idre_brand.dart';
import 'package:idre/startup/idre_native_splash_platforms.dart';
import 'package:idre/startup/idre_splash_screen_metrics.dart';

/// The animated splash screen filling the whole screen: brand background + [IdreSplashAnimation] in the center.
///
/// It continues the native splash screen without any visible jump:
/// - same colors: the brand colors of the **system** light/dark mode (`MediaQuery.platformBrightnessOf`), not the
///   theme chosen in the app, because the native splash can only follow the system;
/// - same size and position of the "i" ([IdreSplashScreenMetrics]);
/// - same first frame: where a native splash exists the animation skips the pop-in
///   ([IdreSplashAnimation.startsFromNativeSplashFrame]) and the "i" stays still for
///   [IdreSplashTimeline.pauseAfterNativeSplashHandOff] before sliding.
///
/// It is centered in the whole screen (no `SafeArea`), like the native image.
class IdreFullScreenSplash extends StatelessWidget {
  const new({super.key, required this.onCompleted});

  /// Called once, when the wordmark is complete.
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final bool isSystemInDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final Color backgroundColor = isSystemInDarkMode
        ? IdreBrandColors.darkBackground
        : IdreBrandColors.lightBackground;
    final Color logoColor = isSystemInDarkMode
        ? IdreBrandColors.logoColorOnDarkBackground
        : IdreBrandColors.logoColorOnLightBackground;

    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size splashSize = IdreSplashScreenMetrics.splashSizeFor(constraints.biggest);
          final bool isNativeSplashShownBeforeFlutter = IdreNativeSplashPlatforms.isNativeSplashShownBeforeFlutter;
          return Center(
            child: SizedBox.fromSize(
              size: splashSize,
              child: IdreSplashAnimation(
                color: logoColor,
                // The letters may fly in from anywhere on the screen.
                clipToBounds: false,
                startsFromNativeSplashFrame: isNativeSplashShownBeforeFlutter,
                // The "i" settles for a moment before sliding, so the hand-off does not feel rushed.
                pauseBeforeStarting: isNativeSplashShownBeforeFlutter
                    ? IdreSplashTimeline.pauseAfterNativeSplashHandOff
                    : Duration.zero,
                onCompleted: onCompleted,
              ),
            ),
          );
        },
      ),
    );
  }
}
