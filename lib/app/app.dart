import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = localizationProvider.currentLocale;
    localizationProvider.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    localizationProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _currentLocale = localizationProvider.currentLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      key: ValueKey(_currentLocale), // Force rebuild when locale changes
      locale: _currentLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('it'),
        Locale('pt'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Healer Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConstants.primary,
          primary: ColorConstants.primary,
          onPrimary: ColorConstants.onPrimary,
          secondary: ColorConstants.secondary,
          onSecondary: ColorConstants.onSecondary,
          background: ColorConstants.background,
          onBackground: ColorConstants.onBackground,
          surface: ColorConstants.surface,
          onSurface: ColorConstants.onSurface,
          error: ColorConstants.error,
          onError: ColorConstants.onError,
        ),
        scaffoldBackgroundColor: ColorConstants.background,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
