import 'package:go_router/go_router.dart';
import 'package:idre/showcase/idre_brand_showcase_page.dart';
import 'package:material_ui/material_ui.dart';

/// The routes of the app.
///
/// The router is created **once** (`static final`), never inside a `build` method: a new `GoRouter` on every
/// rebuild of the app widget would send the user back to the first page (for example when the theme changes).
///
/// Temporary: plain `GoRoute`s; they will become typed routes with go_router_builder.
abstract final class IdreRouter {
  /// The single router of the app, given to `MaterialApp.router(routerConfig: ...)`.
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hello World!'),
                ElevatedButton(
                  onPressed: () => context.push('/brand-showcase'),
                  child: const Text('Go to brand showcase'),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/brand-showcase',
        builder: (BuildContext context, GoRouterState state) => const IdreBrandShowcasePage(),
      ),
    ],
  );
}
