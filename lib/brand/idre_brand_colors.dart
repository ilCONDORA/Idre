import 'dart:ui';

/// Fixed colors of the Idre brand (decided 2026-11-21, from the "Idre" palettes made on realtimecolors.com).
///
/// The logo is always **green**: mint on dark backgrounds, forest green on light backgrounds.
/// The violet accent of the app palettes is intentionally NOT used in the logo, so Idre is never
/// mistaken for the official Jellyfin client (whose brand is purple/blue).
///
/// These values are used for places that do not follow the user's theme: launcher icons,
/// the native splash screen, store assets and previews. Inside the app, prefer the colors of
/// the active theme (`Theme.of(context).colorScheme.primary`).
abstract final class IdreBrandColors {
  /// Logo color on dark backgrounds (`primary` of the dark palette). Contrast on [darkBackground]: 13.4:1.
  static const Color logoColorOnDarkBackground = Color(0xFF99E6B9);

  /// Logo color on light backgrounds (`primary` of the light palette). Contrast on [lightBackground]: 6.4:1.
  static const Color logoColorOnLightBackground = Color(0xFF196739);

  /// Background of the dark palette; also the background of the app icon tile.
  static const Color darkBackground = Color(0xFF090D0B);

  /// Background of the light palette.
  static const Color lightBackground = Color(0xFFF3F7F5);
}
