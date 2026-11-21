import 'package:idre/brand/idre_brand_colors.dart';
import 'package:material_ui/material_ui.dart';

/// The two fixed color schemes of Idre (light and dark).
///
/// ## Where these values come from
/// The 5 colors of each realtimecolors.com palette were expanded into all the Material 3 roles
/// with these rules (the comments show the resulting WCAG contrast; minimum 4.5:1 for text,
/// 3:1 for borders):
/// - surfaces ("floors") = background + 4 / 7 / 11 / 16 % of the text color;
/// - foreground colors weaker than 4.5:1 on the background were lightened (dark theme:
///   secondary `#0908aa` → `#7070ce`, accent `#9434f5` → `#a14cf6`), keeping their hue;
/// - the original secondary and accent are kept as container (fill) colors;
/// - "on" colors are the palette text or background, whichever reads better.
///
/// The themes never change at runtime, so the values are written here directly as `const`:
/// no computation at startup, and every color can be read (and searched) in one place.
abstract final class IdreColorSchemes {
  /// Dark scheme, from the realtimecolors.com palette:
  /// text `#eef5f1`, background `#090d0b`, primary `#99e6b9`, secondary `#0908aa`, accent `#9434f5`.
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    // Main actions: play button, progress bars, focus ring.
    primary: IdreBrandColors.logoColorOnDarkBackground, // 13.4:1 on surface
    onPrimary: Color(0xFF090D0B), // 13.4:1 on primary
    primaryContainer: Color(0xFF26382E),
    onPrimaryContainer: Color(0xFF99E6B9), // 8.5:1 on primaryContainer
    // Selections: selected chips, navigation indicator, tonal buttons.
    secondary: Color(0xFF7070CE), // 4.6:1 on surface
    onSecondary: Color(0xFF090D0B), // 4.6:1 on secondary
    secondaryContainer: Color(0xFF0908AA),
    onSecondaryContainer: Color(0xFFEEF5F1), // 11.7:1 on secondaryContainer
    // Highlights (palette "accent"): "New" badges, favorites.
    tertiary: Color(0xFFA14CF6), // 4.5:1 on surface
    onTertiary: Color(0xFF090D0B), // 4.5:1 on tertiary
    tertiaryContainer: Color(0xFF9434F5),
    onTertiaryContainer: Color(0xFFEEF5F1), // 4.7:1 on tertiaryContainer
    // Errors: Material 3 baseline reds.
    error: Color(0xFFFFB4AB), // 11.5:1 on surface
    onError: Color(0xFF690005), // 7.7:1 on error
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6), // 7.2:1 on errorContainer
    // Page and text.
    surface: IdreBrandColors.darkBackground,
    onSurface: Color(0xFFEEF5F1), // 17.7:1 on surface
    onSurfaceVariant: Color(0xFF9EA4A1), // 7.7:1 on surface
    // Surface "floors": cards, menus, dialogs (higher = further from the background).
    surfaceDim: Color(0xFF090D0B),
    surfaceBright: Color(0xFF2E3230),
    surfaceContainerLowest: Color(0xFF060807),
    surfaceContainerLow: Color(0xFF121614),
    surfaceContainer: Color(0xFF191D1B),
    surfaceContainerHigh: Color(0xFF222724),
    surfaceContainerHighest: Color(0xFF2E3230),
    // Borders and dividers.
    outline: Color(0xFF5C605E), // 3.1:1 on surface
    outlineVariant: Color(0xFF2E3230),
    // Inverse colors: snackbars (a light bar in a dark theme and vice versa).
    inverseSurface: Color(0xFFEEF5F1),
    onInverseSurface: Color(0xFF090D0B), // 17.7:1 on inverseSurface
    inversePrimary: Color(0xFF65987A), // 3.0:1 on inverseSurface
    // Misc.
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: IdreBrandColors.logoColorOnDarkBackground,
  );

  /// Light scheme, from the realtimecolors.com palette:
  /// text `#09100c`, background `#f3f7f5`, primary `#196739`, secondary `#5555f7`, accent `#6b0acd`.
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    // Main actions: play button, progress bars, focus ring.
    primary: IdreBrandColors.logoColorOnLightBackground, // 6.4:1 on surface
    onPrimary: Color(0xFFF3F7F5), // 6.4:1 on primary
    primaryContainer: Color(0xFFD2E1D9),
    onPrimaryContainer: Color(0xFF196739), // 5.1:1 on primaryContainer
    // Selections: selected chips, navigation indicator, tonal buttons.
    secondary: Color(0xFF5555F7), // 4.8:1 on surface
    onSecondary: Color(0xFFF3F7F5), // 4.8:1 on secondary
    secondaryContainer: Color(0xFF5555F7),
    onSecondaryContainer: Color(0xFFF3F7F5), // 4.8:1 on secondaryContainer
    // Highlights (palette "accent"): "New" badges, favorites.
    tertiary: Color(0xFF6B0ACD), // 7.6:1 on surface
    onTertiary: Color(0xFFF3F7F5), // 7.6:1 on tertiary
    tertiaryContainer: Color(0xFF6B0ACD),
    onTertiaryContainer: Color(0xFFF3F7F5), // 7.6:1 on tertiaryContainer
    // Errors: Material 3 baseline reds.
    error: Color(0xFFBA1A1A), // 6.0:1 on surface
    onError: Color(0xFFFFFFFF), // 6.5:1 on error
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002), // 13.3:1 on errorContainer
    // Page and text.
    surface: IdreBrandColors.lightBackground,
    onSurface: Color(0xFF09100C), // 17.8:1 on surface
    onSurfaceVariant: Color(0xFF5B615E), // 5.9:1 on surface
    // Surface "floors": cards, menus, dialogs (higher = further from the background).
    surfaceDim: Color(0xFFD9DEDB),
    surfaceBright: Color(0xFFF3F7F5),
    surfaceContainerLowest: Color(0xFFFAFCFB),
    surfaceContainerLow: Color(0xFFEAEEEC),
    surfaceContainer: Color(0xFFE3E7E5),
    surfaceContainerHigh: Color(0xFFD9DEDB),
    surfaceContainerHighest: Color(0xFFCED2D0),
    // Borders and dividers.
    outline: Color(0xFF8A8E8C), // 3.1:1 on surface
    outlineVariant: Color(0xFFCED2D0),
    // Inverse colors: snackbars (a light bar in a dark theme and vice versa).
    inverseSurface: Color(0xFF09100C),
    onInverseSurface: Color(0xFFF3F7F5), // 17.8:1 on inverseSurface
    inversePrimary: Color(0xFF226D41), // 3.1:1 on inverseSurface
    // Misc.
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: IdreBrandColors.logoColorOnLightBackground,
  );
}
