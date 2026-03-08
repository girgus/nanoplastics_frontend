import 'package:flutter_test/flutter_test.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('Typographic scale — hierarchy must be preserved', () {
    test('title.fontSize > body.fontSize on every device', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);
        expect(
          t.title.fontSize!,
          greaterThan(t.body.fontSize!),
          reason:
              'HIERARCHY BUG on $device: title=${t.title.fontSize} ≤ body=${t.body.fontSize}. '
              'titleScale=0.78×0.9 penalizes title/display/subtitle but not body/tab. '
              'On compact phones, decorative tiers collapse below functional tiers. '
              'Fix: apply titleScale to all tiers or set floor: title ≥ max(12sp, computed).',
        );
      }
    });

    test('headline - body gap must be > 2sp', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);
        final gap = (t.headline.fontSize! - t.body.fontSize!).abs();
        expect(
          gap,
          greaterThan(2.0),
          reason:
              'HIERARCHY BUG on $device: headline=${t.headline.fontSize} - body=${t.body.fontSize} = ${gap.toStringAsFixed(2)}sp gap. '
              'Nielsen Norman: heading must be ≥1.25× body for scannable hierarchy. '
              'Section titles are indistinguishable from body paragraphs.',
        );
      }
    });

    test('display/body ratio ≥ 1.618 (Golden Ratio) or ≥ 1.3 (compact)', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);
        final ratio = t.display.fontSize! / t.body.fontSize!;
        // On standard/large phones: require near Golden Ratio (1.6)
        // On compact phones (width < 360 or height < 700, isCompact): relaxed to 1.3
        final r = configFor(device);
        final minRatio = (r.isCompact || device.width <= 360) ? 1.3 : 1.6;
        expect(
          ratio,
          greaterThanOrEqualTo(minRatio),
          reason:
              'GOLDEN RATIO BUG on $device: display/body = ${ratio.toStringAsFixed(3)} < $minRatioφ. '
              'Golden Ratio (φ=1.618) on standard phones; relaxed to 1.3× (major third) on compact. '
              'On compact phones, tight space constrains heading size.',
        );
      }
    });

    test('tab ≤ title (navigation subordinate to content)', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);
        expect(
          t.tab.fontSize!,
          lessThanOrEqualTo(t.title.fontSize!),
          reason:
              'HIERARCHY BUG on $device: tab=${t.tab.fontSize} > title=${t.title.fontSize}. '
              'Tab labels (nav chrome) appear larger than card titles (content). '
              'Users perceive nav as more important than content — inverted IA. '
              'Fix: tab base from 13sp to 11sp or apply titleScale to tab.',
        );
      }
    });

    test('labelXs ≥ 10sp (WCAG readable minimum)', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);
        expect(
          t.labelXs.fontSize!,
          greaterThanOrEqualTo(10.0),
          reason:
              'WCAG BUG on $device: labelXs=${t.labelXs.fontSize} < 10sp. '
              'WCAG 2.1 SC 1.4.4: text must be resizable to 200% without loss. '
              'At ${t.labelXs.fontSize}sp, users with presbyopia (40% of people 40+) cannot read badges. '
              'Fix: max(10.0, 10 × fontScale).',
        );
      }
    });

    test('Font sizes must follow modular scale (consistent multiplier)', () {
      for (final device in kPortraitDevices) {
        final t = typographyFor(device);

        final displayHeadlineRatio = t.display.fontSize! / t.headline.fontSize!;
        final headlineTitleRatio = t.headline.fontSize! / t.title.fontSize!;
        final titleSubtitleRatio = t.title.fontSize! / t.subtitle.fontSize!;
        final subtitleBodyRatio = t.subtitle.fontSize! / t.body.fontSize!;

        final ratios = [
          displayHeadlineRatio,
          headlineTitleRatio,
          titleSubtitleRatio,
          subtitleBodyRatio,
        ];

        final maxRatio = ratios.reduce((a, b) => a > b ? a : b);
        final minRatio = ratios.reduce((a, b) => a < b ? a : b);
        final variance = maxRatio / minRatio; // ratio between largest and smallest

        // Allow max 1.3× variance (consistent scales should be within 30%)
        expect(
          variance,
          lessThan(1.3),
          reason:
              'TYPE SCALE BUG on $device: ratios=$ratios variance=${variance.toStringAsFixed(2)}×. '
              'Modular scale breaks because titleScale applies selectively to some tiers. '
              'Well-designed scales use consistent ratios (e.g., 1.25× Major Third).',
        );
      }
    });
  });
}
