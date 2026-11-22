import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:idre/startup/idre_full_screen_splash.dart';

/// Shows the animated splash screen on top of the app at a cold start, then fades it away.
///
/// ## What happens
/// 1. The app (the [child]: the router with the first page) is built **at once, under the splash**. While the
///    logo animates, the first page is already there and can start loading its data.
/// 2. When the animation ends, the final wordmark stays for [finalWordmarkHoldDuration], then the splash fades
///    out in [fadeOutDuration], revealing the page.
/// 3. The splash is removed from the widget tree for good.
///
/// The splash **never waits** for any loading: it always lasts the same time, and the page shows its own loading
/// state if its data is not ready yet. The user never stares at a logo that turned into a loader.
///
/// ## Only at a cold start
/// The gate is created in `MaterialApp.router(builder: ...)`, once per app process, and it reads
/// [isSplashScreenEnabled] only once, in `initState`. Coming back from the background keeps the same state, so
/// the splash is not shown again; changing the setting while the app is open affects the next start.
///
/// ## Why not a `/splash` route
/// A route would replace the URL: on the web, opening or reloading `/library/123` would land on `/splash` and
/// the original address would have to be saved and restored. The gate lives outside the router, so URLs,
/// deep links and the back button are untouched.
class IdreStartupGate extends StatefulWidget {
  const new({super.key, required this.isSplashScreenEnabled, required this.child});

  /// The user setting at start-up. `false` = the app is shown at once, without splash. Read only once.
  final bool isSplashScreenEnabled;

  /// The app shown under the splash (the `routerChild` given by `MaterialApp.router`).
  final Widget child;

  /// How long the complete wordmark stays still before the splash fades out.
  static const Duration finalWordmarkHoldDuration = Duration(milliseconds: 200);

  /// Duration of the fade from the splash to the app.
  static const Duration fadeOutDuration = Duration(milliseconds: 350);

  @override
  State<IdreStartupGate> createState() => _IdreStartupGateState();
}

class _IdreStartupGateState extends State<IdreStartupGate> {
  /// `true` while the splash hides the app: the app gets no taps, keyboard focus or screen reader focus.
  late bool _isSplashCoveringTheApp;

  /// `true` until the fade-out has ended; then the splash is removed from the tree.
  late bool _isSplashInTheTree;

  /// Waits [IdreStartupGate.finalWordmarkHoldDuration] after the animation, before the fade-out.
  Timer? _finalWordmarkHoldTimer;

  @override
  void initState() {
    super.initState();
    // Decided once: later changes of the setting do not show or hide the splash while the app is running.
    _isSplashCoveringTheApp = widget.isSplashScreenEnabled;
    _isSplashInTheTree = widget.isSplashScreenEnabled;
  }

  @override
  void dispose() {
    _finalWordmarkHoldTimer?.cancel();
    super.dispose();
  }

  void _fadeOutAfterTheFinalWordmarkHold() {
    _finalWordmarkHoldTimer = Timer(IdreStartupGate.finalWordmarkHoldDuration, () {
      if (!mounted) {
        return;
      }
      final bool areAnimationsDisabled = MediaQuery.disableAnimationsOf(context);
      setState(() {
        _isSplashCoveringTheApp = false;
        if (areAnimationsDisabled) {
          // No fade when the user disabled animations: the splash disappears at once.
          _isSplashInTheTree = false;
        }
      });
    });
  }

  void _removeSplashFromTheTree() {
    if (_isSplashCoveringTheApp) {
      return;
    }
    setState(() => _isSplashInTheTree = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        // The app is always the FIRST child: when the splash (second child) is removed, Flutter keeps the
        // app's element and state (current page, navigation history) instead of rebuilding it.
        ExcludeFocus(
          excluding: _isSplashCoveringTheApp,
          child: ExcludeSemantics(
            excluding: _isSplashCoveringTheApp,
            child: widget.child,
          ),
        ),
        if (_isSplashInTheTree)
          // During the fade-out the page underneath can already be used.
          IgnorePointer(
            ignoring: !_isSplashCoveringTheApp,
            child: AnimatedOpacity(
              opacity: _isSplashCoveringTheApp ? 1 : 0,
              duration: IdreStartupGate.fadeOutDuration,
              curve: Curves.easeOut,
              onEnd: _removeSplashFromTheTree,
              // While the splash covers the app, taps on it do not reach the page underneath.
              child: AbsorbPointer(
                child: IdreFullScreenSplash(onCompleted: _fadeOutAfterTheFinalWordmarkHold),
              ),
            ),
          ),
      ],
    );
  }
}
