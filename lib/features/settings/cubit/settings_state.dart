part of 'settings_cubit.dart';

@immutable
final class SettingsState {
  const new({this.isSplashScreenEnabled = true});

  factory fromJson(Map<String, dynamic> json) {
    return SettingsState(
      isSplashScreenEnabled: json['isSplashScreenEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSplashScreenEnabled': isSplashScreenEnabled,
    };
  }

  final bool isSplashScreenEnabled;

  SettingsState copyWith({bool? isSplashScreenEnabled}) {
    return SettingsState(
      isSplashScreenEnabled: isSplashScreenEnabled ?? this.isSplashScreenEnabled,
    );
  }
}
