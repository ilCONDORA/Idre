# Idre — brand and theme notes

Short log of questions and answers about the `lib/brand` and `lib/theme` folders.
Read it before changing the logo or the colors.

## Q: How is the code organized? (2026-11-21)

**A:** two plain folders inside `lib/` (no separate packages, no tests: simpler and lighter).

```text
lib/
  brand/                          → logo, wordmark, splash, loaders, brand colors (only Flutter widgets)
    idre_brand.dart               → index: import this to get the whole folder
    idre_brand_colors.dart        → IdreBrandColors (logo green, backgrounds)
    idre_logo_geometry.dart       → IdreLogoGeometry: the ONLY place where the logo shape lives
    idre_tentacle_position.dart   → enum: outerLeft, innerLeft, innerRight, outerRight
    idre_tentacle_role.dart       → enum: serverLink, letterD, letterR, letterE
    idre_tentacle_specification.dart
    idre_icon_painter.dart        → CustomPainter of the static logo
    idre_icon.dart                → IdreIcon widget
  theme/                          → colors of the app (`package:material_ui/material_ui.dart`)
    idre_theme.dart               → index: import this to get the whole folder
    idre_color_schemes.dart       → IdreColorSchemes.light / .dark (const ColorScheme)
    idre_themes.dart              → IdreThemes.light / .dark (ThemeData for MaterialApp)
```

Requirements: Flutter ≥ 3.50 and `material_ui` in `pubspec.yaml`. Never import
`package:flutter/material.dart`: its `ThemeData` is a different type from the `material_ui` one
("The argument type 'ThemeData' can't be assigned to the parameter type 'ThemeData?'").

## Q: How do I use the themes? (2026-11-21)

```dart
void main() => runApp(const IdreApp()); // the app widget is const

class IdreApp extends StatelessWidget {
  const IdreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: IdreThemes.light,
      darkTheme: IdreThemes.dark,
      themeMode: ThemeMode.system,
    );
  }
}
```

`ThemeData` cannot be `const` (its constructor is a `factory`); `IdreThemes` uses `static final`,
so each theme is built once, the first time it is read, and then reused.

## Q: Where do the colors come from? (2026-11-21)

Two palettes made on realtimecolors.com. The theme never changes at runtime, so all Material 3
roles were computed once (with automatic WCAG contrast checks) and written as `const` values in
`idre_color_schemes.dart`; each foreground color has its contrast ratio in a comment.

| Variable   | Dark      | Light     |
|------------|-----------|-----------|
| text       | `#eef5f1` | `#09100c` |
| background | `#090d0b` | `#f3f7f5` |
| primary    | `#99e6b9` | `#196739` |
| secondary  | `#0908aa` | `#5555f7` |
| accent     | `#9434f5` | `#6b0acd` |

- Dark palette: secondary (1.5:1) and accent (3.8:1) are too weak as text on the background, so they
  are used as fills (`secondaryContainer`, `tertiaryContainer`) and lighter versions are used as
  foreground (`secondary` `#7070ce`, `tertiary` `#a14cf6`).
- The logo is always green (mint on dark, forest green on light). The violet accent is a light nod
  to Jellyfin's purple: fine in the UI, kept out of the logo.

If a color must change: edit the value in `idre_color_schemes.dart` and keep its contrast comment
true (minimum 4.5:1 for text, 3:1 for borders). The logo colors live in `IdreBrandColors`.

## Q: Which widgets are there, and how do I test them? (2026-11-21)

| Widget                | What it is                                                              |
|-----------------------|-------------------------------------------------------------------------|
| `IdreIcon`            | Static logo (the "i" with 4 tentacles)                                  |
| `IdreWordmark`        | Static "idre" (logo + letters) = last frame of the splash              |
| `IdreSplashAnimation` | "i" pops in the center, slides left, tentacles bring d, r, e, retract |
| `IdreCompactLoader`   | The "i" with tentacles lighting up in cascade, then off in the same order |
| `IdrePulseLoader`     | Wordmark with pulses: in from the server tentacle, out to the letters  |

To see them all: `home: const IdreBrandShowcasePage()` (folder `lib/showcase`, has replay, slow motion
and a light/dark switch). Delete the folder when it is not needed anymore.

How the code is split (same idea everywhere: geometry ≠ time ≠ painting):

- **Geometry** (where things are): `IdreLogoGeometry` (icon, 120×120 units),
  `IdreWordmarkGeometry` (wordmark, 260×150 units: letters, anchor points, arc bends).
- **Time** (when things happen): `IdreSplashTimeline`, every phase as a window of 0.0–1.0.
- **Painting**: `IdreWordmarkPainter` (splash frame for any progress; progress 1.0 = static wordmark),
  `IdrePulseLoaderPainter`, `IdreIconPainter`. Painters receive the animation via
  `super(repaint: animation)`: they repaint every frame without rebuilding widgets.
- **Shared helpers**: `IdreTentacleCurve` (curve between two points, pieces of a path for pulses),
  `IdreBrandPaints` (round strokes and fills).

Splash details: `onCompleted` is called exactly once; with system animations disabled the final
wordmark is shown at once (`MediaQuery.disableAnimationsOf`). Bug found while testing: in that case
`onCompleted` was called twice (setting `value = 1` marks the controller as completed and fired the
status listener too) → the listener is now registered only when the animation really plays.

## Q: Cascade compact loader, rounder pulse-loader arcs, tentacles not ending in one point? (2026-11-21)

**A:**

- **Compact loader**: tentacles light up one after the other — outer left, outer right, inner left,
  inner right — then switch off in the same order (`_IdreCompactLoaderState.lightingOrder`; change the list
  to change the cascade). Cycle: 1.8 s.
- **Tentacle shapes**: every tentacle is described by 4 points (`IdreTentacleCurvePoints`, a cubic Bézier).
  A stretched ("connected") tentacle leaves the head **from its own resting position and direction**,
  arcs over the letters and lands on its letter from above. Resting and stretched shapes have the same
  format, so the splash **morphs** one into the other: tentacles stretch out of the resting fan and
  go back into it (no more three tentacles ending in the same point).
- **Roles reassigned** so the arcs are nested and never cross (the tentacle that starts further left
  reaches the letter further right): inner left → "e", inner right → "r", outer right → "d",
  outer left = server link. Anchors: top of "d", top of "r", top of "e".
- The arc parameters (`connectedTentacleDepartureLength`, `connectedTentacleLandingOffset`) were tuned with
  a script so arcs keep ≥ 12.5 design units from each other and from the letters.
- **Two design areas**: `staticDesignArea` (tight, for `IdreWordmark`) and `animatedDesignArea`
  (taller, room for the arcs above the letters, for the splash and the pulse loader).

## Q: How many tentacles and why? (2026-11-21)

**A:** 4, symmetric 2 + 2 fan: 4 platform families (mobile, desktop, web, TV), each pair like the
arcs of a Wi-Fi symbol; the outer-left tentacle is the link to the Jellyfin server, the other three
grab the letters d, r, e in the splash screen.
