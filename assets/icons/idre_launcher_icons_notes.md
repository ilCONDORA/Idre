# Idre — launcher icons and app name notes

## Q: How are the app icons set up? (2026-11-21)

**A:** `flutter_launcher_icons.yaml` + six 1024 × 1024 images in `assets/icons/`, rendered from the logo code
(`IdreIconPainter`, standard geometry, mint `#99e6b9` on `#090d0b`). Run `dart run flutter_launcher_icons`.
The images do NOT need to be listed under `flutter: assets:` in `pubspec.yaml`: the tool reads them directly.

The logo is sized by its **enclosing circle** (smallest circle containing the whole logo: center (60, 61),
radius 45.07 design units), scaled to the limit of each platform — like round logos (Spotify, Telegram, Immich)
that fill almost the whole icon:

| Image                    | Used for                                   | Enclosing circle |
|--------------------------|--------------------------------------------|------------------|
| `icon_IosWeb.png`        | iOS (opaque)                               | 80 % of the icon |
| `icon_Web.png`           | web favicon + PWA icons (transparent)      | 98 % of the icon |
| `icon_IosDark.png`       | iOS 18 dark (transparent background)       | 80 %             |
| `icon_IosTinted.png`     | iOS 18 tinted (white on black)             | 80 %             |
| `icon_AndForeground.png` | Android adaptive icon, front layer         | radius 305 px = edge of the 66 dp safe zone |
| `icon_AndMonochrome.png` | Android 13+ themed icon (white, transparent) | same as foreground |
| `icon_Desk.png`          | macOS, Android < 8 (rounded tile, 824 px, 100 px margin) | 80 % of the tile |
| `icon_Win.png`           | Windows (rounded tile 984 px, 20 px margin) | 80 % of the tile |

- Android: launchers show only the central 72 of 108 dp and crop it to their shape; the logo touches the edge of
  the 66 dp "safe zone" (never cropped), so `adaptive_icon_foreground_inset: 0`.
- Linux is not handled by `flutter_launcher_icons`.
- Windows: `generate: false`. The tool writes a single-size (256 px) .ico, blurry in the taskbar; instead
  `windows/runner/resources/app_icon.ico` is a hand-made multi-size .ico (16, 24, 32, 48, 64, 128, 256) made
  from `icon_Win.png`. If the icon changes, rebuild it (e.g. with Pillow or any .ico tool) from `icon_Win.png`.

## Q: Can the logo fill more of the icon? (2026-11-21)

**A:** yes: first version used ~55 % of the height (39 % on Android); now every image is scaled to the limit of
its platform using the enclosing circle (about 1.5× bigger on Android). Checked with simulated masks.

## Q: Favicon without background; Windows taskbar icon too small? (2026-11-21)

**A:** (superseded by the next answer) first attempt: SVG favicon and a Windows image with the small-size logo.
Windows → its own image `icon_Win.png`
(edge-to-edge tile instead of the macOS margins, thicker small-size logo) and a multi-size .ico.
Android unchanged (already right).

## Q: Favicon and Windows icon looked different (tentacles close to the dot)? (2026-11-21)

**A:** they used `IdreLogoGeometry.smallSize()` (bigger head, thicker strokes, wider fan), which changes the look.
All icons now use the **standard** geometry. Favicon → `icon_Web.png` (transparent PNG, logo filling the square;
the SVG favicon was dropped). Windows → `icon_Win.png` with the standard logo on an edge-to-edge tile, plus the
multi-size .ico. Rule: every launcher icon uses the same geometry as the app icon.

## Q: "Idre" or "idre"? (2026-11-21)

**A:** "Idre" wherever a person reads the name (icon label, window title, PWA name, store); lowercase only in
technical ids (`com.ilcondora.idre`, `idre-win`, `idre-linux`) and in the logo wordmark.

## Q: Copyright: real name or GitHub name? (2026-11-21)

**A:** Both are acceptable in a notice; the real name identifies the owner unambiguously, the pseudonym keeps
the real name out of public metadata. Use the same holder name as the LICENSE file, if the code is published.
Use "©" (U+00A9), not "©️" (with the emoji variation selector).
