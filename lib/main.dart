import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'config/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';
import 'screens/web/web_landing_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/settings_manager.dart';
import 'services/service_locator.dart';
import 'services/update_service.dart';
import 'utils/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Settings Manager
  await SettingsManager.init();

  // Persist current app version from PackageInfo
  try {
    final info = await PackageInfo.fromPlatform();
    await SettingsManager().setCurrentAppVersion(info.version);
  } catch (e) {
    debugPrint('Error reading app version: $e'); // ignore: avoid_print
  }

  // Initialize Service Locator (all singleton services)
  // Build type is determined at compile time via BuildConfig.bundleAllLangs.
  await ServiceLocator().initialize();

  final serviceLocator = ServiceLocator();
  final logger = serviceLocator.loggerService;
  logger.logAppLifecycle('App Starting...');

  // Set status bar style — both modes use dark surfaces, so always light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Both modes have dark surfaces
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Keep native apps portrait-first, but let web use full desktop layouts.
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Note: Firebase is already initialized in LoggerService.initialize()

  // Schedule version check after 5 seconds
  Future.delayed(const Duration(seconds: 5), () {
    ServiceLocator().updateService.checkForUpdates();
  });

  runApp(const RestartableApp());
}

class RestartableApp extends StatefulWidget {
  const RestartableApp({super.key});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartableAppState>()?.restartApp();
  }

  @override
  State<RestartableApp> createState() => _RestartableAppState();
}

class _RestartableAppState extends State<RestartableApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: const NanoSolveHiveApp(),
    );
  }
}

class NanoSolveHiveApp extends StatefulWidget {
  const NanoSolveHiveApp({super.key});

  static Future<void> changeLocale(BuildContext context, Locale locale) {
    return context
            .findAncestorStateOfType<_NanoSolveHiveAppState>()
            ?.setLocale(locale) ??
        Future.value();
  }

  @override
  State<NanoSolveHiveApp> createState() => _NanoSolveHiveAppState();
}

class _NanoSolveHiveAppState extends State<NanoSolveHiveApp>
    with TickerProviderStateMixin {
  late Locale _locale;
  late Function(UpdateState, double) _updateListener;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    final settingsManager = SettingsManager();
    final languageCode = settingsManager.userLanguage;
    _locale = Locale(languageCode);

    _fadeController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 150),
    );

    // Attach global update listener for automatic notifications
    _attachUpdateListener();
  }

  Future<void> setLocale(Locale locale) async {
    await _fadeController.animateTo(0.0);
    if (!mounted) return;
    setState(() => _locale = locale);
    await _fadeController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 220),
    );
  }

  void _attachUpdateListener() {
    _updateListener = (state, progress) {
      if (!mounted) return;
      // Rebuild UI to show/hide update badge on settings icon
      setState(() {});
    };
    ServiceLocator().updateService.addStateListener(_updateListener);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    ServiceLocator().updateService.removeStateListener(_updateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = SettingsManager();
    final shouldShowOnboarding = !settingsManager.hasShownOnboarding;

    final darkModeEnabled = settingsManager.darkModeEnabled;

    return MaterialApp(
      title: 'NanoSolve Hive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      navigatorObservers: [routeObserver],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English (default)
        Locale('cs', ''), // Czech
        Locale('es', ''), // Spanish
        Locale('ru', ''), // Russian
        Locale('fr', ''), // French
      ],
      locale: _locale,
      home: kIsWeb
          ? const WebLandingScreen()
          : (shouldShowOnboarding
              ? const OnboardingScreen()
              : const MainScreen()),
    );
  }
}
