# Idre — splash screen notes

## Q: How do we integrate the splash widget? flutter_native_splash, animated_splash_screen or custom? (2026-11-21)

**A:** a mix: `flutter_native_splash` for the native part + a custom Flutter splash.

- **Native part** (Android, iOS, web): what the system shows before Flutter starts. Only a still image is possible
  (GIFs work only on the web), and Android 12+ always shows a centered icon anyway, so we need the package to
  control that moment. The image is the "i" at rest in the center = the first frame of the Flutter animation.
- **Flutter part**: `IdreSplashAnimation`, shown by `IdreStartupGate`.
- `animated_splash_screen` rejected: last release July 2022, it is only a Flutter widget with a timer and a push
  navigation (extra `page_transition` dependency), it does nothing native and does not know go_router.

## Q: Implement it: the page must open as soon as the splash ends, without waiting for any init (2026-11-22)

**A:** done. How it works:

```text
tap on the icon → native splash: "i" still in the center (Android, iOS, web)
  → first Flutter frame: the SAME "i" (the native splash disappears by itself, nobody sees the switch)
  → the "i" slides left, the tentacles bring d, r, e   (desktop: the "i" pops in first)
  → final wordmark held 200 ms → fade 350 ms → the page, already built underneath
```

- **No waiting**: the router and the first page are built at once **under** the splash, so the page can start
  loading while the logo animates. The splash always lasts the same time; the page shows its own loading states.
- **Cold start only**: the gate lives in `MaterialApp.router(builder: ...)` (built once per process) and reads the
  setting only in `initState`. Back from the background = no splash.
- **User setting**: `SettingsCubit.updateIsSplashScreenEnabled(...)`, saved by hydrated_bloc, used at the next start.
- **Not a `/splash` route**: on the web it would replace the URL (deep links, reload). The gate sits outside the
  router, so URLs and the back button are untouched.
- **Same colors as the native splash**: the Flutter splash follows the **system** light/dark mode, not the app
  theme, because the native splash can only follow the system. When the user picks a different theme in the app,
  the fade simply reveals the themed page.
- **Same size**: `IdreSplashScreenMetrics.designUnitInLogicalPixels = 1.17` (the circle around the "i" ≈ 120 logical
  pixels). The Python script reads that value from the Dart file, so the image and the Flutter frame stay in sync.
  On a window smaller than the splash (narrow desktop/browser window) the splash shrinks to fit.
- **Hand-off frame**: `IdreSplashAnimation(startsFromNativeSplashFrame: true)` starts at
  `IdreSplashTimeline.handOffFromNativeSplashProgress` (= start of the slide), skipping the pop-in.
  `IdreNativeSplashPlatforms.isNativeSplashShownBeforeFlutter` says where (Android, iOS, web).
- `FlutterNativeSplash.preserve()/remove()` are NOT used: the native splash must disappear at the first Flutter frame,
  so `flutter_native_splash` is only a dev dependency. If `preserve()` is ever needed, move it to `dependencies`.

### Files

| File | What |
|------|------|
| `lib/startup/idre_startup_gate.dart` | Splash on top of the app, fade-out, cold start only, setting |
| `lib/startup/idre_full_screen_splash.dart` | Background + centered animation, system light/dark colors |
| `lib/startup/idre_splash_screen_metrics.dart` | Size of the splash (shared with the native images) |
| `lib/startup/idre_native_splash_platforms.dart` | Which platforms have a native splash |
| `lib/router/idre_router.dart` | The `GoRouter`, created once (it was created inside `build`) |
| `tool/generate_native_splash_images.py` | Draws `assets/splash/splash_icon_{dark,light}.png` (1152 px, 4x = 288 logical px) |
| `flutter_native_splash.yaml` | Native splash config (same images for Android 12+) |

### Commands (after changing the "i" or `designUnitInLogicalPixels`)

```bash
python3 tool/generate_native_splash_images.py   # needs pycairo; checks the Android 12 visible circle
dart run flutter_native_splash:create
```

### Other changes in the same step

- `SettingsCubit` provider moved **above** `MaterialApp`, so settings can drive `MaterialApp` (theme mode) later.
- The `GoRouter` was created in `build`: every rebuild of the app widget would reset navigation → `IdreRouter.router`.
- The gate is always in the tree (also with the splash disabled), so the router never changes parent.
- `title: 'Idre'` added to `MaterialApp.router` (browser tab, task switcher).

### Still to check on a real device

- Android 12+ (Fold 8, One UI): the icon must not jump at the hand-off; if it does, adjust only
  `designUnitInLogicalPixels` and regenerate.
- macOS: the window appears before the first frame; set its background to the brand color in
  `macos/Runner/MainFlutterWindow.swift` if a flash is visible.

## Q: On the emulator the native "i" disappears, then the Flutter splash appears already moving and feels too fast (2026-11-22)

**A:** two separate problems.

1. **The gap ("the i disappears")** — Android removes its splash when the Activity draws its first frame, but
   Flutter may still be loading: in between, the window showed the `NormalTheme` background (`?android:colorBackground`,
   white/black). Fixes:
   - `MainActivity.kt`: the Activity skips its frames (`OnPreDrawListener` returning `false`) until
     `onFlutterUiDisplayed()`, so the native splash stays until the Flutter splash is ready. Safety valve: 10 s.
   - Android 12+: native splash removed at once (`setOnExitAnimationListener { it.remove() }`), no fade-out flicker.
   - `NormalTheme` background = brand color (`@color/idre_window_background`, `values` + `values-night`): it is still
     visible for an instant on rotation and when folding/unfolding (Fold), so it must match the app.
   - After `dart run flutter_native_splash:create`, check that `NormalTheme` in the 4 `styles.xml` still uses
     `@color/idre_window_background`.
2. **"Too fast"** — skipping the pop-in made the first Flutter frame already the slide. Now the "i" stays still for
   `IdreSplashTimeline.pauseAfterNativeSplashHandOff` (400 ms) and the timer starts **after the first frame is drawn**
   (`IdreSplashAnimation.pauseBeforeStarting`), so slow first frames do not eat the pause. Total ≈ 0.4 + 1.36 s.
   If it still feels fast, raise `IdreSplashTimeline.defaultDuration`.

Judge timing in **release** (`flutter run --release`), not debug: debug builds are JIT-compiled and their first
frames are much slower and jumpy. Profile mode does not run on emulators.

Leftover `android/app/src/main/kotlin/com/example/idre/MainActivity.kt` (old package before `package_rename`):
deleted.

**Result (2026-11-22):** tested in release on the Android emulator and on the web — hand-off and timing confirmed.
Still to test: iOS, and the Fold 8 when folding/unfolding.
