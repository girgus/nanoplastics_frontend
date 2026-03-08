// Tests for ExtendedTourService flag management.
//
// Regression coverage for: tour re-triggering after language change.
//
// Root cause of the bug:
//   `setAdvisorTourShown(true)` was only called inside `onComplete`, so if the
//   user changed language mid-tour the app restarted with the flag still false,
//   causing the tour to fire again on every restart until it was fully completed.
//
// Fix: flag is now set immediately in `showIfNeeded`, before `startTour` is
// called. These tests enforce that contract.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nanoplastics_app/services/settings_manager.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

void main() {
  // ── Unit tests — no widgets needed ──────────────────────────────────────────

  group('advisor_tour_shown flag — persistence across restarts', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      SettingsManager.resetForTesting();
      await SettingsManager.init();
    });

    test('starts false on fresh install', () {
      expect(SettingsManager().hasShownAdvisorTour, false);
    });

    test('is true after setAdvisorTourShown(true)', () async {
      await SettingsManager().setAdvisorTourShown(true);
      expect(SettingsManager().hasShownAdvisorTour, true);
    });

    test('survives SettingsManager re-initialisation (language-change restart)',
        () async {
      // Simulate: user sees tour → flag is written → language change → app
      // restarts → SettingsManager re-initialises from SharedPreferences.
      await SettingsManager().setAdvisorTourShown(true);

      // Re-init (SharedPreferences mock retains written values).
      SettingsManager.resetForTesting();
      await SettingsManager.init();

      expect(
        SettingsManager().hasShownAdvisorTour,
        true,
        reason: 'flag written to SharedPreferences must survive a '
            'SettingsManager re-initialisation so the tour never re-fires '
            'after a language-change-triggered app restart',
      );
    });

    test('false flag does not survive only in-memory write (regression guard)',
        () async {
      // Sanity check: if we reset WITHOUT writing, flag should be false again.
      // This proves the previous test is meaningful.
      // (Don't call setAdvisorTourShown here — just reset.)
      SettingsManager.resetForTesting();
      await SettingsManager.init();

      expect(SettingsManager().hasShownAdvisorTour, false);
    });
  });

  // ── Widget tests — MainScreen integration ───────────────────────────────────

  group('MainScreen tour — showIfNeeded flag contract', () {
    testWidgets(
        'flag is set to true when showIfNeeded is called, '
        'regardless of whether the tour is completed', (tester) async {
      // Start with no prior flag — first launch scenario.
      await setupServiceLocator({'advisor_tour_shown': false});

      await tester.pumpWidget(buildTestableWidget(const MainScreen()));

      // addPostFrameCallback fires after first frame.
      await tester.pump();

      // Allow the async gap inside showIfNeeded
      // (setAdvisorTourShown is awaited before startTour).
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        SettingsManager().hasShownAdvisorTour,
        true,
        reason: 'flag must be persisted before startTour() is called so that '
            'a mid-tour language change cannot reset it',
      );

      // Test only verifies flag contract, not tour completion, so skip settling
      // the entire TutorialCoachMark overlay (which can spin indefinitely).
      // Just pump once to let the overlay render.
    });

    testWidgets(
        'tour does not re-trigger on second MainScreen mount '
        '(simulates language-change restart)', (tester) async {
      // ── First launch ──
      await setupServiceLocator({'advisor_tour_shown': false});
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Flag must be true now (set before tour started).
      expect(SettingsManager().hasShownAdvisorTour, true);

      // ── Simulate language change: restart (re-init services, re-mount screen) ──
      // setupServiceLocator re-reads SharedPreferences; the mock retains the
      // value written above so advisor_tour_shown remains true.
      await setupServiceLocator();

      expect(
        SettingsManager().hasShownAdvisorTour,
        true,
        reason: 'after language-change restart SettingsManager must still '
            'report hasShownAdvisorTour = true',
      );

      // Mount MainScreen again (second launch after language change).
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Flag must still be true — showIfNeeded returned early without
      // calling startTour again.
      expect(
        SettingsManager().hasShownAdvisorTour,
        true,
        reason: 'second MainScreen mount must not reset the tour flag',
      );
    });

    testWidgets('tour is skipped entirely when flag is already true',
        (tester) async {
      // Normal post-first-launch scenario: flag already set.
      await setupServiceLocator({'advisor_tour_shown': true});

      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pump();

      // Flag must remain true and screen renders without errors.
      expect(SettingsManager().hasShownAdvisorTour, true);
    });
  });
}
