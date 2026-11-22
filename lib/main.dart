import 'package:condora_foundation/condora_foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:idre/features/settings/cubit/settings_cubit.dart';
import 'package:idre/router/idre_router.dart';
import 'package:idre/startup/idre_startup_gate.dart';
import 'package:idre/theme/idre_theme.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // While this runs, the native splash screen is still on screen: it disappears by itself when Flutter draws its
  // first frame, which is already the first frame of the animated splash (see IdreStartupGate).
  HydratedBloc.storage = await buildHydratedStorage();

  runApp(const IdreApp());
}

/// The root widget of Idre.
class IdreApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Idre',
        theme: IdreThemes.light,
        darkTheme: IdreThemes.dark,
        routerConfig: IdreRouter.router,
        // The gate is always in the tree (also with the splash disabled), so the router never changes parent.
        builder: (context, routerChild) => IdreStartupGate(
          isSplashScreenEnabled: context.read<SettingsCubit>().state.isSplashScreenEnabled,
          child: routerChild!,
        ),
      ),
    );
  }
}
