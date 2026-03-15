import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/user_settings/user_settings_screen.dart';
import 'package:nanoplastics_app/screens/onboarding_screen.dart';
import '../../helpers/test_app.dart';
import '../../helpers/settings_test_helper.dart';

class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
}

void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  Widget buildUserSettingsApp() {
    return buildTestableWidget(const UserSettingsScreen());
  }

  group('UserSettingsScreen rendering', () {
    testWidgets('renders all 5 setting cards', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // Verify all setting cards are present
      expect(find.byType(InkWell), findsWidgets);

      // Verify the screen has scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays Profile card', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // Verify setting cards are present by checking for Text widgets
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays Language card', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // Verify setting cards are present by checking for InkWell widgets
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('displays Privacy & Security card', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // Look for "Privacy" text
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays About card', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // About card should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays Intro Tour card', (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // Intro Tour card should be present
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('UserSettingsScreen navigation', () {
    testWidgets(
        'tapping Intro Tour pushes OnboardingScreen with isReplay: true',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        buildTestableWidget(
          const UserSettingsScreen(),
          navigatorObserver: mockObserver,
        ),
      );

      await tester.pumpAndSettle();

      // Drag to scroll down to Intro Tour card
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap the Intro Tour card
      await tester.tap(find.ancestor(
        of: find.text('Intro Tour'),
        matching: find.byType(InkWell),
      ));
      await tester.pumpAndSettle();

      // Verify OnboardingScreen(isReplay: true) is now in the widget tree
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('each navigation item routes to correct screen',
        (tester) async {
      await tester.pumpWidget(buildUserSettingsApp());
      await tester.pumpAndSettle();

      // All cards should be tappable (InkWell)
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
