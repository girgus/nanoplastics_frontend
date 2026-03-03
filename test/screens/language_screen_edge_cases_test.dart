import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/language_screen.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  group('LanguageScreen selection guards', () {
    testWidgets('selecting already-selected language is no-op', (tester) async {
      // Default language is English
      int callbackCount = 0;

      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {
            callbackCount++;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Tap English (already selected) — should be no-op
      // Find the InkWell ancestor of the English text
      await tester.tap(find.ancestor(
        of: find.text('English').first,
        matching: find.byType(InkWell),
      ));
      await tester.pumpAndSettle();

      // Callback should NOT fire (early return at line 48)
      expect(callbackCount, equals(0));
      expect(SettingsManager().userLanguage, equals('en'));
    });

    testWidgets(
        'selecting different language updates SettingsManager immediately',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to Czech and tap it
      await tester.ensureVisible(find.text('Czech'));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
        of: find.text('Czech'),
        matching: find.byType(InkWell),
      ));
      await tester.pumpAndSettle();

      // SettingsManager should be updated immediately (line 51)
      expect(SettingsManager().userLanguage, equals('cs'));
    });

    // TODO: This test requires Czech to be pre-set before widget build.
    // The LanguageScreen reads language at build time, so setUserLanguage()
    // after setUp() doesn't propagate to the widget properly.
    // Need to refactor test setup or LanguageScreen initialization logic.
    //
    // testWidgets('onLanguageChanged callback receives correct Locale',
    //     (tester) async {
    //   // Start from Czech so we can switch to English without triggering a
    //   // download (English is always available; non-EN requires a download in
    //   // LITE builds which would block the callback in the test environment).
    //   final settingsManager = SettingsManager();
    //   await settingsManager.setUserLanguage('cs');
    //
    //   Locale? receivedLocale;
    //
    //   await tester.pumpWidget(buildTestableWidget(
    //     LanguageScreen(
    //       onLanguageChanged: (locale) {
    //         receivedLocale = locale;
    //       },
    //     ),
    //   ));
    //   await tester.pumpAndSettle();
    //
    //   // Tap English — no download needed, callback fires immediately
    //   // Find the InkWell ancestor of the English text
    //   await tester.tap(find.ancestor(
    //     of: find.text('English').first,
    //     matching: find.byType(InkWell),
    //   ));
    //   await tester.pumpAndSettle();
    //
    //   expect(receivedLocale, equals(const Locale('en')));
    // });
  });

  group('LanguageScreen UI state', () {
    testWidgets('checkmark moves to newly selected language', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        LanguageScreen(
          onLanguageChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Initially English is selected — one checkmark
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Scroll to French and tap it
      await tester.ensureVisible(find.text('French'));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
        of: find.text('French'),
        matching: find.byType(InkWell),
      ));
      await tester.pumpAndSettle();

      // Checkmark should still exist (now on French)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('all 5 language codes are correct', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const LanguageScreen(),
      ));
      await tester.pumpAndSettle();

      // Verify each language option exists with correct native name
      final expectedPairs = {
        'English': 'English',
        'Czech': 'Čeština',
        'Spanish': 'Español',
        'French': 'Français',
        'Russian': 'Русский',
      };

      for (final entry in expectedPairs.entries) {
        if (entry.key == 'English') {
          // English appears as both name and nativeName
          expect(find.text('English'), findsWidgets);
        } else {
          expect(find.text(entry.key), findsOneWidget,
              reason: 'Missing language name: ${entry.key}');
          expect(find.text(entry.value), findsOneWidget,
              reason: 'Missing native name: ${entry.value}');
        }
      }
    });
  });
}
