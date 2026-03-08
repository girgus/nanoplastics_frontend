import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';
import 'package:nanoplastics_app/screens/category_detail_new_screen.dart';
import 'package:nanoplastics_app/screens/category_evidence_screen.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() async {
    await setupSettingsManager();
  });

  Future<void> openEvidencePreview(WidgetTester tester) async {
    final control = tester.widget(find.byKey(const ValueKey('evidence-preview-open')));
    if (control is InkWell) {
      expect(control.onTap, isNotNull);
      control.onTap!();
    } else {
      (control as dynamic).onPressed();
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets(
      'category detail screen shows evidence preview and brainstorm box',
      (tester) async {
    final data = CategoryDetailDataFactory.centralSystems(l10n);

    await tester.pumpWidget(
      buildTestableWidget(CategoryDetailNewScreen(categoryData: data)),
    );
    await tester.pump();

    expect(find.text('YOUR IDEA FOR THIS TOPIC'), findsNothing);
    expect(find.text(l10n.categoryDetailBrainstormTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('evidence-preview-open')), findsOneWidget);
  });

  testWidgets('evidence preview navigates to evidence screen', (tester) async {
    final data = CategoryDetailDataFactory.centralSystems(l10n);

    await tester.pumpWidget(
      buildTestableWidget(CategoryDetailNewScreen(categoryData: data)),
    );
    await tester.pump();

    await openEvidencePreview(tester);

    expect(
        find.byKey(const ValueKey('category-evidence-screen')), findsOneWidget);
    expect(find.byType(CategoryEvidenceScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('evidence-study-card-1')), findsOneWidget);
  });

  testWidgets('returning from evidence screen preserves draft idea text',
      (tester) async {
    final data = CategoryDetailDataFactory.entryGates(l10n);

    await tester.pumpWidget(
      buildTestableWidget(CategoryDetailNewScreen(categoryData: data)),
    );
    await tester.pump();

    await tester.enterText(
      find.byType(TextField),
      'This is a detailed idea that should survive navigation.',
    );
    await tester.pump();

    await openEvidencePreview(tester);

    expect(find.byType(CategoryEvidenceScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(CategoryEvidenceScreen))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(
      textField.controller!.text,
      equals('This is a detailed idea that should survive navigation.'),
    );
  });

  testWidgets('evidence screen renders on narrow layouts without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final data = CategoryDetailDataFactory.physicalProperties(l10n);

    await tester.pumpWidget(
      buildTestableWidget(CategoryEvidenceScreen(categoryData: data)),
    );
    await tester.pump();

    expect(
        find.byKey(const ValueKey('category-evidence-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
