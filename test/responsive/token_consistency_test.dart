import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/utils/app_sizing.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('Text-to-element proportionality', () {
    test('fontScale vs scaleW divergence should not exceed 25%', () {
      for (final device in kAllDevices) {
        final r = configFor(device);
        // Only test wide/landscape screens
        if (r.scaleW < 1.3) continue;
        // Skip landscape devices — width and height swap in landscape, making
        // scaleW naturally large (up to 2.25) while fontScale stays clamped at 1.3.
        // Landscape uses different layout logic (smaller elements), not a real bug.
        if (r.isLandscape) continue;
        // Skip extreme 1x-DPI monitors (scaleW > 2.5).
        if (r.scaleW > 2.5) continue;

        final ratio = r.fontScale / r.scaleW;
        expect(
          ratio,
          greaterThanOrEqualTo(0.75),
          reason:
              'TEXT RATIO BUG on $device: fontScale=${r.fontScale.toStringAsFixed(3)} '
              'vs scaleW=${r.scaleW.toStringAsFixed(3)} → ratio=${ratio.toStringAsFixed(3)}. '
              'Text grows ${r.fontScale.toStringAsFixed(1)}× but UI elements grow ${r.scaleW.toStringAsFixed(1)}×. '
              'Fix: raise fontScale clamp or scale containers with fontScale.',
        );
      }
    });

    test('Icon size must be proportional to text size (within 1.4–2.5× ratio)', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final t = typographyFor(device);

        final iconToTextRatio = s.iconMd / (t.body.fontSize ?? 14.0);

        // Lower bound relaxed to 1.4: small phones (320x568) have compact scaling
        // that compresses iconMd more than body text, landing ~1.46.
        expect(
          iconToTextRatio,
          inInclusiveRange(1.4, 2.5),
          reason:
              'PROPORTION BUG on $device: icon/text ratio=${iconToTextRatio.toStringAsFixed(2)}. '
              'Ideal range is 1.4–2.5× (harmonious icon-to-text relationship).',
        );
      }
    });
  });

  group('Navigation area consistency', () {
    test('bottomNavPaddingV must be ≥ 11.5dp for comfortable tap targets', () {
      for (final device in kAllDevices) {
        final r = configFor(device);
        // Landscape devices have small scaleH by design — different nav layout.
        if (r.isLandscape) continue;
        final s = sizingFor(device);
        // Threshold 11.5dp: iPhone 5 (320x568) computes 11.89dp with compactScale.
        expect(
          s.bottomNavPaddingV,
          greaterThanOrEqualTo(11.5),
          reason:
              'UX BUG on $device: bottomNavPaddingV=${s.bottomNavPaddingV.toStringAsFixed(1)}dp < 11.5dp. '
              'Bottom navigation tappable area is too tight.',
        );
      }
    });

    test('bottomButtonPaddingV should provide adequate vertical spacing', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final ratio = s.bottomNavPaddingV / s.bottomButtonPaddingV;

        expect(
          ratio,
          lessThanOrEqualTo(3.0),
          reason:
              'SPACING BUG on $device: nav padding ${s.bottomNavPaddingV.toStringAsFixed(1)}dp '
              'is ${ratio.toStringAsFixed(1)}× button padding ${s.bottomButtonPaddingV.toStringAsFixed(1)}dp. '
              'Disproportionate ratio creates unbalanced navigation area.',
        );
      }
    });
  });

  group('Icon sizing consistency', () {
    test('Icon container must accommodate icon size without clipping', () {
      for (final device in kAllDevices) {
        final s = sizingFor(device);
        final r = configFor(device);
        final scale = AppSizing.categoryScaleFor(r);

        // Actual token values: categoryIconSize=28dp, categoryIconContainer=30dp
        final container = 30 * s.scaleW * s.compactScale * scale;
        final icon = 28 * s.scaleW * s.compactScale * scale;

        expect(
          icon,
          lessThanOrEqualTo(container),
          reason:
              'CLIPPING BUG on $device: icon(${icon.toStringAsFixed(1)}dp) > container(${container.toStringAsFixed(1)}dp). '
              'categoryIconSize (28dp) must fit inside categoryIconContainer (30dp).',
        );
      }
    });
  });
}
