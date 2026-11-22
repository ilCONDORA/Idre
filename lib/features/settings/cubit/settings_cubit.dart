import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

/// The user settings of the app, saved on the device by hydrated_bloc and restored at every start.
class SettingsCubit extends HydratedCubit<SettingsState> {
  new() : super(const SettingsState());

  /// Turns the animated splash screen on or off. It takes effect at the next start of the app.
  void updateIsSplashScreenEnabled({required bool isSplashScreenEnabled}) {
    emit(state.copyWith(isSplashScreenEnabled: isSplashScreenEnabled));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) => SettingsState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SettingsState state) => state.toJson();
}
