import 'package:flutter/material.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';
import '../main.dart';

/// Shared language selection logic for screens that support language switching.
/// Handles language selection, PDF downloads, and app restart.
mixin LanguageSelectionMixin<T extends StatefulWidget> on State<T> {
  /// List of supported languages with flags and codes.
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'flag': '🇸🇦', 'name': 'العربية'},
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский'},
    {'code': 'cs', 'flag': '🇨🇿', 'name': 'Čeština'},
  ];

  late SettingsManager settingsManager;
  late String selectedLanguage;
  bool _isChangingLanguage = false;

  /// Initialize language state (call in initState).
  void initLanguageSelection() {
    settingsManager = ServiceLocator().settingsManager;
    selectedLanguage = settingsManager.userLanguage;
  }

  /// Handle language selection with animated locale switch.
  Future<void> selectLanguage(String code) async {
    if (selectedLanguage == code || _isChangingLanguage) return;

    setState(() {
      selectedLanguage = code;
      _isChangingLanguage = true;
    });

    await settingsManager.setUserLanguage(code);

    // Wait for icon selection animation to finish before fading
    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      await NanoSolveHiveApp.changeLocale(context, Locale(code));
      if (mounted) setState(() => _isChangingLanguage = false);
    }
  }
}
