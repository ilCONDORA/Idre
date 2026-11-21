import 'package:idre/brand/idre_brand.dart';
import 'package:idre/theme/idre_theme.dart';
import 'package:material_ui/material_ui.dart';

/// A page to see and test every brand element: logo, wordmark, splash animation and loaders.
///
/// Temporary helper for development: show it with `home: const IdreBrandShowcasePage()`
/// and delete the `showcase` folder when it is not needed anymore.
///
/// It has its own light/dark switch (it wraps itself in the Idre theme), so both themes
/// can be checked without changing the system settings.
class IdreBrandShowcasePage extends StatefulWidget {
  const new({super.key});

  @override
  State<IdreBrandShowcasePage> createState() => _IdreBrandShowcasePageState();
}

class _IdreBrandShowcasePageState extends State<IdreBrandShowcasePage> {
  /// How much slower the splash plays in slow motion, to check every phase.
  static const int slowMotionFactor = 4;

  bool isDarkThemeEnabled = true;
  bool isSlowMotionEnabled = false;

  /// Changing this number gives the splash a new key, which restarts its animation.
  int splashReplayCount = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkThemeEnabled ? IdreThemes.dark : IdreThemes.light,
      // Builder: gives a new BuildContext that already "sees" the Theme above.
      child: Builder(
        builder: (themedContext) {
          final ColorScheme colorScheme = Theme.of(themedContext).colorScheme;
          final Color brandColor = colorScheme.primary;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 16,
              title: IdreWordmark(height: 36, color: brandColor),
              actions: [
                IconButton(
                  tooltip: isDarkThemeEnabled ? 'Light theme' : 'Dark theme',
                  icon: Icon(isDarkThemeEnabled ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => isDarkThemeEnabled = !isDarkThemeEnabled),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _ShowcaseSection(
                  title: 'Splash',
                  child: Column(
                    spacing: 12,
                    children: [
                      SizedBox(
                        height: 220,
                        child: IdreSplashAnimation(
                          key: ValueKey<int>(splashReplayCount),
                          color: brandColor,
                          duration: IdreSplashTimeline.defaultDuration * (isSlowMotionEnabled ? slowMotionFactor : 1),
                        ),
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => setState(() => splashReplayCount++),
                            icon: const Icon(Icons.replay),
                            label: const Text('Replay'),
                          ),
                          FilterChip(
                            label: const Text('Slow motion'),
                            selected: isSlowMotionEnabled,
                            onSelected: (isSelected) => setState(() {
                              isSlowMotionEnabled = isSelected;
                              splashReplayCount++;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _ShowcaseSection(
                  title: 'Loaders',
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IdreCompactLoader(size: 24, color: brandColor),
                      IdreCompactLoader(size: 48, color: brandColor),
                      IdreCompactLoader(size: 72, color: brandColor),
                      IdrePulseLoader(height: 72, color: brandColor),
                    ],
                  ),
                ),
                _ShowcaseSection(
                  title: 'Wordmark',
                  child: IdreWordmark(height: 96, color: brandColor),
                ),
                _ShowcaseSection(
                  title: 'Logo',
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      for (final double iconSize in const [16.0, 24.0, 32.0, 48.0, 72.0])
                        IdreIcon(size: iconSize, foregroundColor: brandColor),
                      // App icon look: fixed brand colors on the rounded tile.
                      const IdreIcon(
                        size: 96,
                        foregroundColor: IdreBrandColors.logoColorOnDarkBackground,
                        backgroundColor: IdreBrandColors.darkBackground,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A titled card that groups one brand element.
class _ShowcaseSection extends StatelessWidget {
  const new({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Card(
        color: theme.colorScheme.surfaceContainer,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
