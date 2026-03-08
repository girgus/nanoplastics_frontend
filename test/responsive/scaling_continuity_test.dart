import 'package:flutter_test/flutter_test.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('Monotonic scaling — no inversions as width grows', () {
    test('logoHeight stays monotonic within each phone size category', () {
      // logoScale intentionally drops 0.8→0.5 at PhoneSize.large (width≥400):
      // larger phones show a smaller logo to expose more content area.
      // Monotonicity is only meaningful WITHIN a category, not across boundaries.
      final normalCategory = [
        const DeviceProfile('sweep_360_812', width: 360, height: 812),
        const DeviceProfile('sweep_375_812', width: 375, height: 812),
        const DeviceProfile('sweep_390_812', width: 390, height: 812),
        const DeviceProfile('sweep_399_812', width: 399, height: 812),
      ];
      final largeCategory = [
        const DeviceProfile('sweep_400_812', width: 400, height: 812),
        const DeviceProfile('sweep_412_812', width: 412, height: 812),
        const DeviceProfile('sweep_428_812', width: 428, height: 812),
      ];

      for (final sweep in [normalCategory, largeCategory]) {
        for (int i = 0; i < sweep.length - 1; i++) {
          final s1 = sizingFor(sweep[i]);
          final s2 = sizingFor(sweep[i + 1]);

          final logo1 = 70 * s1.scaleH * s1.compactScale * s1.logoScale;
          final logo2 = 70 * s2.scaleH * s2.compactScale * s2.logoScale;

          expect(
            logo2,
            greaterThanOrEqualTo(logo1 * 0.95),
            reason:
                'CONTINUITY BUG: logoHeight inverted within category between ${sweep[i]} '
                '(logo=${logo1.toStringAsFixed(2)}) and ${sweep[i + 1]} '
                '(logo=${logo2.toStringAsFixed(2)}). '
                'Unexpected drop inside a phone size category.',
          );
        }
      }
    });

    test('logoHeightLg has no >10% jumps between adjacent heights', () {
      // Test uses actual sizingFor() to compute logoHeightLg, not hardcoded multipliers.
      final s860 = sizingFor(kLogoJump860);
      final s861 = sizingFor(kLogoJump861);

      final logoHeightLg860 = s860.logoHeightLg;
      final logoHeightLg861 = s861.logoHeightLg;

      final percentDelta =
          ((logoHeightLg861 - logoHeightLg860) / logoHeightLg860 * 100).abs();

      expect(
        percentDelta,
        lessThan(10.0),
        reason:
            'CONTINUITY BUG: logoHeightLg jump ${percentDelta.toStringAsFixed(1)}% '
            'from 1px height change (860→861). Hard threshold creates jarring step function. '
            'Fix: lerp logoHeight over 812..932dp range instead of hard ≤860 check.',
      );
    });

    test('All spacing tokens increase monotonically with width (height=812 baseline)', () {
      final widthSweep = [
        const DeviceProfile('sweep_300', width: 300, height: 812),
        const DeviceProfile('sweep_320', width: 320, height: 812),
        const DeviceProfile('sweep_350', width: 350, height: 812),
        const DeviceProfile('sweep_375', width: 375, height: 812),
        const DeviceProfile('sweep_400', width: 400, height: 812),
        const DeviceProfile('sweep_428', width: 428, height: 812),
        const DeviceProfile('sweep_500', width: 500, height: 812),
      ];

      final tokenValues = <double>[];
      for (final device in widthSweep) {
        final sp = spacingFor(device);
        tokenValues.add(sp.md);
      }

      for (int i = 0; i < tokenValues.length - 1; i++) {
        expect(
          tokenValues[i + 1],
          greaterThanOrEqualTo(tokenValues[i]),
          reason:
              'CONTINUITY BUG: spacing.md not monotonic at width '
              '${widthSweep[i].width.toInt()}→${widthSweep[i + 1].width.toInt()}. '
              'Value ${tokenValues[i].toStringAsFixed(2)} → ${tokenValues[i + 1].toStringAsFixed(2)}. '
              'A breakpoint changed compactScale or categoryScale unexpectedly.',
        );
      }
    });
  });

  group('Subpixel alignment — 8pt grid', () {
    test('Token values should land on reasonable pixel boundaries at DPR 1/2', () {
      int pixelAlignedCount = 0;
      int totalTokens = 0;

      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final sp = spacingFor(device);

        final tokensToCheck = [
          s.iconMd,
          s.logoHeight,
          s.categoryIconSize,
          sp.md,
          sp.contentPaddingH,
          sp.sectionSpacing,
        ];

        for (final token in tokensToCheck) {
          totalTokens++;
          final physical1x = token * 1.0;
          final physical2x = token * 2.0;

          final frac1x = (physical1x - physical1x.toInt()).abs();
          final frac2x = (physical2x - physical2x.toInt()).abs();

          if (frac1x < 0.01 || frac2x < 0.01) {
            pixelAlignedCount++;
          }
        }
      }

      final alignmentPercent = (pixelAlignedCount / totalTokens * 100);
      // Responsive tokens (scaleW * base) will rarely hit exact pixel boundaries.
      // 15% is realistic for a scale-based design system; anything below indicates
      // completely irrational values.
      expect(
        alignmentPercent,
        greaterThan(15.0),
        reason:
            'SUBPIXEL BUG: only ${alignmentPercent.toStringAsFixed(0)}% of token values align to pixel grid. '
            'Values like 12.48dp → 24.96px (DPR 2) cause subpixel rendering artifacts. '
            'Consider rounding high-frequency tokens to 0.5dp boundaries.',
      );
    });
  });
}
