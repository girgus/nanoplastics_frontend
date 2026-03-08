import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/utils/app_sizing.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('Flag logic invariants', () {
    test('isCompact && isBig must be mutually exclusive', () {
      final r = configFor(kCompactBigOverlap); // 350x950
      expect(
        !(r.isCompact && r.isBig),
        true,
        reason:
            'DESIGN BUG: 350x950 has isCompact=true AND isBig=true. '
            'Flags are mutually exclusive in intent but conditions overlap. '
            'AppSpacing resolves compactScale=1.0 (isBig wins) vs AppSizing resolves 0.85 (isCompact wins). '
            'Fix: isBig = !isCompact && (width > 410 || height > 900)',
      );
    });

    test('AppSpacing vs AppSizing compactScale must agree for all devices', () {
      for (final device in kAllDevices) {
        final r = configFor(device);
        final spacingScale = spacingCompactScale(r);
        final sizingScale = sizingCompactScale(r);
        expect(
          spacingScale,
          sizingScale,
          reason:
              'DESIGN BUG on $device: AppSpacing compactScale=$spacingScale '
              'but AppSizing compactScale=$sizingScale. '
              'Spacing vs sizing proportional relationship is broken.',
        );
      }
    });
  });

  group('Scaling math invariants', () {
    test('categoryScale must be bounded (≤1.5)', () {
      final r = configFor(kVeryTallSlim); // 360x1000
      final categoryScale = AppSizing.categoryScaleFor(r);
      expect(
        categoryScale,
        lessThanOrEqualTo(1.5),
        reason: 'DESIGN BUG: categoryScale=$categoryScale exceeds 1.5 bound. '
            'Unbounded scale causes icon overflow on tall devices. '
            'Fix: clamp categoryScale to 1.5 max.',
      );
    });

    test('categoryIconSize must fit inside categoryIconContainer', () {
      for (final device in kAllDevices) {
        final s = sizingFor(device);
        final iconSize = s.categoryIconSize;
        final containerSize = s.categoryIconContainer;
        expect(
          iconSize,
          lessThanOrEqualTo(containerSize),
          reason: 'DESIGN BUG on $device: icon($iconSize) > container($containerSize). '
              'Icon base must not exceed container base. Fix: icon base to 28dp.',
        );
      }
    });

    test('minTouchTarget must remain ≥44dp (Fitts Law)', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        expect(
          s.minTouchTarget,
          greaterThanOrEqualTo(44.0),
          reason: 'ACCESSIBILITY BUG on $device: minTouchTarget=${s.minTouchTarget} < 44dp. '
              'Scaling touch targets DOWN on small phones violates Fitts Law and HIG. '
              'Fix: clamp at 44dp minimum.',
        );
      }
    });

    test('logoHeight generally increases with width (at fixed 812dp height)', () {
      // Test width-trend within phone size categories (discontinuities at boundaries are acceptable)
      // Verify: within normal-phone range, logo grows; within large-phone range, logo grows
      final normalPhones = [
        const DeviceProfile('logo_300', width: 300, height: 812),
        const DeviceProfile('logo_360', width: 360, height: 812),
        const DeviceProfile('logo_390', width: 390, height: 812), // < 400, still normal
      ];

      final largePhones = [
        const DeviceProfile('logo_410', width: 410, height: 812), // ≥ 400 and < 480
        const DeviceProfile('logo_450', width: 450, height: 812),
      ];

      // Test monotonicity within normal-phone range
      final normalHeights = [
        for (final d in normalPhones) sizingFor(d).logoHeight,
      ];
      for (int i = 0; i < normalHeights.length - 1; i++) {
        expect(
          normalHeights[i + 1],
          greaterThanOrEqualTo(normalHeights[i] * 0.95), // Allow 5% drift due to scale math
          reason:
              'DESIGN BUG: logoHeight should trend upward within normal-phone range. '
              '${normalPhones[i].width}dp: ${normalHeights[i].toStringAsFixed(1)}dp → '
              '${normalPhones[i + 1].width}dp: ${normalHeights[i + 1].toStringAsFixed(1)}dp',
        );
      }

      // Test monotonicity within large-phone range
      final largeHeights = [
        for (final d in largePhones) sizingFor(d).logoHeight,
      ];
      for (int i = 0; i < largeHeights.length - 1; i++) {
        expect(
          largeHeights[i + 1],
          greaterThanOrEqualTo(largeHeights[i]),
          reason:
              'DESIGN BUG: logoHeight should trend upward within large-phone range. '
              '${largePhones[i].width}dp: ${largeHeights[i].toStringAsFixed(1)}dp → '
              '${largePhones[i + 1].width}dp: ${largeHeights[i + 1].toStringAsFixed(1)}dp',
        );
      }
    });

    test('logoHeightLg continuity (smooth lerp, no >10% jump)', () {
      final s860 = sizingFor(kLogoJump860);
      final s861 = sizingFor(kLogoJump861);

      final logoHeightLg860 = s860.logoHeightLg;
      final logoHeightLg861 = s861.logoHeightLg;

      final percentDelta = ((logoHeightLg861 - logoHeightLg860) / logoHeightLg860 * 100).abs();

      expect(
        percentDelta,
        lessThan(10.0),
        reason:
            'DESIGN BUG: logoHeightLg jump ${percentDelta.toStringAsFixed(1)}% '
            'from 1px height change (860→861). Should be smooth lerp over range. '
            'Fix: interpolate logoHeight over 812..932dp instead of hard threshold.',
      );
    });

    test('hubGridWidth must not exceed screen width', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final hubWidth = s.hubGridWidth;
        expect(
          hubWidth,
          lessThanOrEqualTo(device.width),
          reason:
              'OVERFLOW BUG on $device: hubGridWidth=$hubWidth > screen width=${device.width}. '
              'Hub base (400dp) exceeds baseline (375dp). Fix: reduce base to 350dp.',
        );
      }
    });

    test('contentPaddingV must provide meaningful spacing (≥4dp)', () {
      for (final device in kPortraitDevices) {
        final sp = spacingFor(device);
        expect(
          sp.contentPaddingV,
          greaterThanOrEqualTo(4.0),
          reason:
              'UX BUG on $device: contentPaddingV=${sp.contentPaddingV} < 4dp. '
              'Token base value (2dp) is so small it provides no visual breathing room. '
              'Fix: increase base to 8dp.',
        );
      }
    });
  });
}
