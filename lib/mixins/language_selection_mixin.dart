import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/build_config.dart';
import '../services/settings_manager.dart';
import '../services/service_locator.dart';
import '../utils/pdf_utils.dart';
import '../utils/app_theme_colors.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

/// Shared language selection logic for screens that support language switching.
/// Handles language selection, PDF downloads, and app restart.
mixin LanguageSelectionMixin<T extends StatefulWidget> on State<T> {
  /// List of supported languages with flags and codes.
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English'},
    {'code': 'cs', 'flag': '🇨🇿', 'name': 'Čeština'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Русский'},
  ];

  late SettingsManager settingsManager;
  late String selectedLanguage;

  /// Initialize language state (call in initState).
  void initLanguageSelection() {
    settingsManager = ServiceLocator().settingsManager;
    selectedLanguage = settingsManager.userLanguage;
  }

  /// Handle language selection with PDF download and app restart.
  Future<void> selectLanguage(String code) async {
    if (selectedLanguage == code) return;

    setState(() => selectedLanguage = code);
    await settingsManager.setUserLanguage(code);

    // Download PDFs for non-EN languages when not all langs are bundled
    if (code != 'en' && !BuildConfig.bundleAllLangs) {
      final success = await _downloadPDFForLanguageWithProgress(code);
      if (!success && mounted) {
        _showOfflineFallbackDialog(code);
        return;
      }
    }

    if (mounted) {
      RestartableApp.restartApp(context);
    }
  }

  /// Download PDF for a specific language with progress feedback.
  Future<bool> _downloadPDFForLanguageWithProgress(String langCode) async {
    try {
      final resolved = await resolveMainReport(langCode);
      if (resolved != null) return true;

      if (!mounted) return false;

      double progress = 0;
      bool isCancelled = false;
      bool dialogDismissed = false;
      late StateSetter dialogSetState;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            dialogSetState = setState;
            return AlertDialog(
              backgroundColor: AppThemeColors.of(context).dialogBackground,
              title: Text(
                AppLocalizations.of(context)!.downloadingLanguage(
                  supportedLanguages
                          .firstWhere((l) => l['code'] == langCode)['name'] ??
                      'Language',
                ),
                style: const TextStyle(color: AppColors.pastelAqua),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.pastelAqua,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppThemeColors.of(context).textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isCancelled = true;
                    dialogDismissed = true;
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await downloadReport(
        langCode,
        onProgress: (progressValue) {
          if (!isCancelled && mounted) {
            dialogSetState(() => progress = progressValue);
          }
        },
      );

      if (isCancelled) return false;

      if (!dialogDismissed && mounted) {
        Navigator.of(context).pop();
        dialogDismissed = true;
      }
      return true;
    } catch (e) {
      // Dialog already dismissed by user cancel or error—no double pop
      return false;
    }
  }

  /// Show fallback dialog when PDF download fails.
  void _showOfflineFallbackDialog(String attemptedLanguage) {
    final langName = supportedLanguages
            .firstWhere((l) => l['code'] == attemptedLanguage)['name'] ??
        'language files';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          AppLocalizations.of(context)!.downloadFailed,
          style: const TextStyle(color: AppColors.pastelAqua),
        ),
        content: Text(
          AppLocalizations.of(context)!.downloadFailedMessage(langName),
          style: TextStyle(color: AppThemeColors.of(context).textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              selectLanguage('en');
            },
            child: Text(
              AppLocalizations.of(context)!.useEnglish,
              style: const TextStyle(color: AppColors.pastelMint),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              selectLanguage(attemptedLanguage);
            },
            child: Text(
              AppLocalizations.of(context)!.retry,
              style: const TextStyle(color: AppColors.pastelAqua),
            ),
          ),
        ],
      ),
    );
  }
}
