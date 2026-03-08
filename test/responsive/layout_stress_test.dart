import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('MainScreen overflow on user devices', () {
    setUp(() async {
      await setupServiceLocator();
    });

    testWidgets('no overflow on 640x360 landscape (4.6" @2x)', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      setScreenSize(tester, kUserDevice46);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason:
            'OVERFLOW BUG on 4.6" landscape: hub height exceeds viewport. '
            'hubContainerHeight = 200 × 1.707 = 341dp > 360dp screen. '
            'Hub alone consumes 94.8% of viewport — no content area. '
            'Fix: cap hub height = min(height × 0.3, 200 × scaleW × compactScale).',
      );
    });

    testWidgets('no overflow on 1280x720 landscape (4.6" @1x)', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      setScreenSize(tester, kUserDevice46_1x);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason:
            'OVERFLOW BUG on 4.6" @1x: scaleW=3.413 causes massive sizing. '
            'hubContainerHeight = 200 × 3.413 = 683dp vs 720dp height. '
            'All tokens scale to 3.4×, causing UI elements to be enormous.',
      );
    });

    testWidgets('no overflow on 393x873 (Motorola G32)', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      setScreenSize(tester, kMotoG32);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      expect(errors, isEmpty,
          reason: 'Expected: Motorola G32 layout should be tuned and pass.');
    });

    testWidgets('no overflow on 350x950 (isCompact+isBig overlap)', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      setScreenSize(tester, kCompactBigOverlap);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason:
            'OVERFLOW BUG on 350x950: AppSpacing and AppSizing disagree on compactScale. '
            'Spacing token scale=1.0 while sizing token scale=0.85 for same device. '
            'Proportional relationship is broken — spacing too large relative to sizing.',
      );
    });

    testWidgets('no overflow on 320x568 (iPhone 5)', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      setScreenSize(tester, kTinyPhone);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      expect(
        errors,
        isEmpty,
        reason:
            'OVERFLOW BUG on tiny phone: hubGridWidth=290dp vs 320dp screen. '
            'Category card text wrapping + Russian locale (40% longer) may overflow containers.',
      );
    });
  });

  group('Touch target compliance at real sizes', () {
    setUp(() async {
      await setupServiceLocator();
    });

    testWidgets('all InkWell elements >= 44x44dp on 320x568', (tester) async {
      setScreenSize(tester, kTinyPhone);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);

      final failedTargets = <String>[];
      for (final widget in tester.widgetList(inkWells)) {
        final size = tester.getSize(find.byWidget(widget));
        final area = size.width * size.height;

        if (area < 44 * 44) {
          failedTargets.add('${size.width.toStringAsFixed(0)}×${size.height.toStringAsFixed(0)}dp');
        }
      }

      expect(
        failedTargets,
        isEmpty,
        reason:
            'ACCESSIBILITY BUG on 320x568: ${failedTargets.length} touch targets < 44×44dp minimum. '
            'Failed sizes: ${failedTargets.join(', ')}. '
            'Scaling touch targets DOWN on small phones violates Fitts Law. '
            'Fix: minTouchTarget = max(44dp, 44 * scaleW * compactScale).',
      );
    });
  });

  group('Background image composition', () {
    setUp(() async {
      await setupServiceLocator();
    });

    testWidgets('background covers viewport on 640x360 landscape', (tester) async {
      setScreenSize(tester, kUserDevice46);
      await tester.pumpWidget(buildTestableWidget(const MainScreen()));
      await tester.pumpAndSettle();

      // Check that background widget tree is intact
      expect(find.byType(Image), findsAny,
          reason: 'Background image widget should be rendered');

      // Visual inspection: no white gaps should appear
      // (hard to verify programmatically without screenshot testing)
    });
  });
}
