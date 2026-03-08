import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/solvers_leaderboard_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/profile_registration_dialog.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';

// Short settle timeout — getTopSolvers() HTTP call never completes in tests.
// Default pumpAndSettle timeout is 10min which would stall the suite.
const _kSettle = Duration(seconds: 3);
const _kStep = Duration(milliseconds: 100);

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle(
      _kStep,
      EnginePhase.sendSemanticsUpdate,
      _kSettle,
    );

void main() {
  group('SolversLeaderboardScreen - unregistered user', () {
    setUp(() async {
      // Empty display_name and email → unregistered
      await setupServiceLocator();
    });

    testWidgets('shows restricted access view when user has no email/name',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await _settle(tester);

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows "Register Now" button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await _settle(tester);

      expect(find.byIcon(Icons.app_registration), findsOneWidget);
    });

    testWidgets('tapping "Register Now" opens ProfileRegistrationDialog',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await _settle(tester);

      await tester.tap(find.byIcon(Icons.app_registration));
      await _settle(tester);

      expect(find.byType(ProfileRegistrationDialog), findsOneWidget);
    });
  });

  group('SolversLeaderboardScreen - registered user', () {
    setUp(() async {
      await setupServiceLocator({
        'display_name': 'John Doe',
        'email': 'john@example.com',
      });
    });

    testWidgets('does not show restricted access view when registered',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const SolversLeaderboardScreen(),
      ));
      await _settle(tester);

      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.app_registration), findsNothing);
    });
  });
}
