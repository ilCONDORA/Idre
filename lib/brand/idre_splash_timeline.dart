import 'package:flutter/animation.dart';

/// When each phase of the splash animation happens.
///
/// The whole animation is a single value `t` going from 0.0 to 1.0 (one `AnimationController`).
/// Each phase owns a window of that range and gets its own local progress (0.0 → 1.0):
///
/// ```text
/// t: 0.0      0.12  0.15         0.38                                       1.0
///    |-- pop --|     |--- slide ---|                                           |
///    i appears       i moves left  |-- d: shoot · pull · retract --|           |
///                                     |-- r: shoot · pull · retract --|        |
///                                        |-- e: shoot · pull · retract --------|
/// ```
///
/// Keeping all the numbers here (and only here) makes the timing easy to tweak.
abstract final class IdreSplashTimeline {
  /// Total duration in production. The "slow motion" in the showcase multiplies it.
  static const Duration defaultDuration = Duration(milliseconds: 1600);

  /// The "i" pops in at the center of the screen.
  static const double headPopStart = 0;
  static const double headPopDuration = 0.12;

  /// The "i" slides from the center to its final position.
  static const double slideStart = 0.15;
  static const double slideDuration = 0.23;

  /// Tentacle phases. Letter number `index` (0 = d, 1 = r, 2 = e) starts
  /// [delayBetweenLetters] after the previous one.
  static const double firstLetterStart = 0.36;
  static const double delayBetweenLetters = 0.06;
  static const double shootDuration = 0.14;
  static const double pullDuration = 0.24;
  static const double retractDuration = 0.14;

  /// Local progress (0.0–1.0) of a phase that starts at [phaseStart] and lasts [phaseDuration].
  static double phaseProgress(double t, {required double phaseStart, required double phaseDuration}) {
    return ((t - phaseStart) / phaseDuration).clamp(0.0, 1.0);
  }

  /// Scale of the "i" while it appears: 0 → slightly over 1 → 1 (a small bounce).
  static double headPopScale(double t) {
    final double popProgress = phaseProgress(t, phaseStart: headPopStart, phaseDuration: headPopDuration);
    return popProgress == 0 ? 0 : Curves.easeOutBack.transform(popProgress);
  }

  /// How far the "i" has slid from the center (0.0) to its final position (1.0).
  static double slideProgress(double t) {
    return Curves.easeInOutCubic.transform(phaseProgress(t, phaseStart: slideStart, phaseDuration: slideDuration));
  }

  /// Tentacle number [letterIndex] stretches from its resting shape to its letter.
  static double shootProgress(double t, int letterIndex) {
    return phaseProgress(t, phaseStart: _letterStart(letterIndex), phaseDuration: shootDuration);
  }

  /// The letter is pulled into its final position.
  static double pullProgress(double t, int letterIndex) {
    return phaseProgress(t, phaseStart: _letterStart(letterIndex) + shootDuration, phaseDuration: pullDuration);
  }

  /// The tentacle goes back to its resting shape.
  static double retractProgress(double t, int letterIndex) {
    return phaseProgress(
      t,
      phaseStart: _letterStart(letterIndex) + shootDuration + pullDuration,
      phaseDuration: retractDuration,
    );
  }

  /// `true` while tentacle number [letterIndex] is away from its resting shape.
  static bool isTentacleStretched(double t, int letterIndex) {
    return shootProgress(t, letterIndex) > 0 && retractProgress(t, letterIndex) < 1;
  }

  static double _letterStart(int letterIndex) => firstLetterStart + letterIndex * delayBetweenLetters;
}
