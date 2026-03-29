import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/onboarding_screen.dart';
import 'package:nanoplastics_app/screens/category_detail_new_screen.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  // ── OnboardingScreen ─────────────────────────────────────────────────────
  // Overflow risk: language-flag Row, slide Column with Flexible container,
  // navigation button Row with SizedBox(width:80) + ElevatedButton.

  group('OnboardingScreen overflow on user devices', () {
    setUp(() async {
      await setupServiceLocator({'onboarding_shown': false});
    });

    testWidgets('no overflow on 320x568 (iPhone 5)', (tester) async {
      setScreenSize(tester, kTinyPhone);
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('no overflow on 640x360 landscape (4.6" @2x)', (tester) async {
      setScreenSize(tester, kUserDevice46);
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('no overflow on 1280x720 landscape (4.6" @1x)', (tester) async {
      setScreenSize(tester, kUserDevice46_1x);
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();
    });

    testWidgets('no overflow on 393x873 (Motorola G32)', (tester) async {
      setScreenSize(tester, kMotoG32);
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pumpAndSettle();
    });
  });

  // ── CategoryDetailNewScreen ──────────────────────────────────────────────
  // Overflow risk: header with scaled icon + title Row, evidence card Rows,
  // detail-entry highlight text, BrainstormBox footer.
  // NOTE: initState calls AnimationController.repeat() — never settles, so
  // pumpAndSettle would time out. pump() is sufficient: overflow errors surface
  // on the very first render frame.

  group('CategoryDetailNewScreen overflow on user devices', () {
    setUp(() async {
      await setupServiceLocator();
    });

    testWidgets('no overflow on 320x568 (iPhone 5) — human central systems',
        (tester) async {
      setScreenSize(tester, kTinyPhone);
      final data = CategoryDetailDataFactory.centralSystems(l10n);
      await tester.pumpWidget(
          buildTestableWidget(CategoryDetailNewScreen(categoryData: data)));
      await tester.pump();
    });

    testWidgets('no overflow on 640x360 landscape — human central systems',
        (tester) async {
      setScreenSize(tester, kUserDevice46);
      final data = CategoryDetailDataFactory.centralSystems(l10n);
      await tester.pumpWidget(
          buildTestableWidget(CategoryDetailNewScreen(categoryData: data)));
      await tester.pump();
    });

    testWidgets('no overflow on 1280x720 landscape — planet world ocean',
        (tester) async {
      setScreenSize(tester, kUserDevice46_1x);
      final data = CategoryDetailDataFactory.worldOcean(l10n);
      await tester.pumpWidget(
          buildTestableWidget(CategoryDetailNewScreen(categoryData: data)));
      await tester.pump();
    });

    testWidgets('no overflow on 393x873 (Motorola G32) — planet world ocean',
        (tester) async {
      setScreenSize(tester, kMotoG32);
      final data = CategoryDetailDataFactory.worldOcean(l10n);
      await tester.pumpWidget(
          buildTestableWidget(CategoryDetailNewScreen(categoryData: data)));
      await tester.pump();
    });
  });
}
