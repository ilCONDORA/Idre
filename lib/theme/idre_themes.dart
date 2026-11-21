import 'package:idre/theme/idre_color_schemes.dart';
import 'package:material_ui/material_ui.dart';

/// The two Idre themes, ready to give to `MaterialApp`.
///
/// ```dart
/// MaterialApp(
///   theme: IdreThemes.light,
///   darkTheme: IdreThemes.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
///
/// ## Why `static final` and not `const`
/// `ThemeData(...)` is a `factory` constructor (it computes its defaults at runtime), so it cannot be
/// `const`. `static final` is the closest thing: Dart builds each theme the first time it is read
/// and then reuses the same object forever, so it is never rebuilt.
/// Make your **app widget** const instead: `runApp(const IdreApp())`.
abstract final class IdreThemes {
  /// Opacity of the focus highlight. Important on TV, where the remote moves the focus.
  static const double focusHighlightOpacity = 0.24;

  /// Light theme.
  static final ThemeData light = _buildThemeData(IdreColorSchemes.light);

  /// Dark theme.
  static final ThemeData dark = _buildThemeData(IdreColorSchemes.dark);

  /// Wraps [colorScheme] in a [ThemeData] with the few component tweaks Idre wants.
  ///
  /// Most widgets already pick the right roles by themselves (for example a selected
  /// `FilterChip` uses `secondaryContainer`); only the differences from Material defaults are listed here.
  static ThemeData _buildThemeData(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      focusColor: colorScheme.primary.withValues(alpha: focusHighlightOpacity),
      // Flat app bar: same color as the page, no tint when content scrolls under it (minimal look).
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      // Watch progress bars: primary fill on a subtle track.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      // Badges ("New", episode counters) use the accent instead of the error red.
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.tertiaryContainer,
        textColor: colorScheme.onTertiaryContainer,
      ),
    );
  }
}
