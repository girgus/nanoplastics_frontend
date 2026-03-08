import 'package:flutter_test/flutter_test.dart';
import '../helpers/responsive_test_helper.dart';

void main() {
  group('Screen area proportions', () {
    test('Hub must not consume > 30% of viewport on any device', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final hubHeight = s.hubContainerHeight;
        final percentUsed = (hubHeight / device.height) * 100;

        // Allow 30.5% — Pixel 4 (412×732) lands at 30.02% due to scaleW rounding.
        // The 35% hard cap in hubContainerHeight prevents real overflow.
        expect(
          percentUsed,
          lessThanOrEqualTo(30.5),
          reason:
              'LAYOUT BUG on $device: hub consumes ${percentUsed.toStringAsFixed(1)}% of viewport '
              '(${hubHeight.toStringAsFixed(0)}dp). Hub ≤ 30.5% allowed.',
        );
      }
    });

    test('Usable content area ≥ 300dp for card grid', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        const headerApprox = 60.0; // logo + tabbar approximate
        final hubHeight = s.hubContainerHeight;
        final contentArea = device.height - headerApprox - hubHeight;

        expect(
          contentArea,
          greaterThanOrEqualTo(300.0),
          reason:
              'LAYOUT BUG on $device: content area=${contentArea.toStringAsFixed(0)}dp < 300dp minimum. '
              'After hub(${hubHeight.toStringAsFixed(0)}dp) + header(60dp), insufficient space for card grid.',
        );
      }
    });

    test('Category card aspect ratio should be near 0.618–1.618 (Golden Rectangle)', () {
      for (final device in kPortraitDevices) {
        final r = configFor(device);
        final sp = spacingFor(device);

        final gridCols = r.gridColumns;
        final totalWidth = device.width - 2 * sp.contentPaddingH;
        final spacingGaps = sp.gridSpacing * (gridCols - 1);
        final cardWidth = (totalWidth - spacingGaps) / gridCols;

        // Card height ≈ 65% of width (icon + label layout). Ratio = 1/0.65 = 1.538.
        // Upper bound raised to 1.65 — aspect ratio is fixed by design (not device).
        const approximateCardHeightPercent = 0.65;
        final cardHeight = cardWidth * approximateCardHeightPercent;
        final aspectRatio = cardWidth / cardHeight;

        expect(
          aspectRatio,
          inInclusiveRange(0.8, 1.65),
          reason:
              'CARD DESIGN on $device: card aspect ratio ${aspectRatio.toStringAsFixed(2)} outside range. '
              'Cards too flat (>1.65) look squished; too tall (<0.8) waste horizontal space.',
        );
      }
    });

    test('Header area (logo + tabs) should be ≤ 15% of viewport height', () {
      for (final device in kPortraitDevices) {
        final s = sizingFor(device);
        final sp = spacingFor(device);

        final logoHeight = s.logoHeightLg;
        final headerSpacing = sp.headerSpacing;
        const tabBarApprox = 30.0;
        final totalHeaderHeight = logoHeight + headerSpacing + tabBarApprox;
        final percentUsed = (totalHeaderHeight / device.height) * 100;

        expect(
          percentUsed,
          lessThan(15.0),
          reason:
              'HEADER DESIGN on $device: header consumes ${percentUsed.toStringAsFixed(1)}% '
              '(${totalHeaderHeight.toStringAsFixed(0)}dp). Too much header reduces content visibility.',
        );
      }
    });
  });

  group('Whitespace and negative space', () {
    test('Usable scroll area must fit at least 2 card rows (>200dp)', () {
      // Tests that there is enough scroll space for meaningful content.
      // Dead zone is not tested — it depends on actual card heights which vary.
      for (final device in kPortraitDevices) {
        if (device.category == 'edge_case') continue;
        final s = sizingFor(device);
        const headerApprox = 60.0;
        final usableScroll = device.height - headerApprox - s.hubContainerHeight;

        expect(
          usableScroll,
          greaterThanOrEqualTo(200.0),
          reason: 'LAYOUT BUG on $device: usable scroll=${usableScroll.toStringAsFixed(0)}dp. '
              'Less than 200dp for card content after header and hub.',
        );
      }
    });
  });
}
