import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/config/build_config.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('selfUpdateSupported', () {
    test('is false on iOS, whatever the distribution flag says', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        BuildConfig.selfUpdateSupported,
        isFalse,
        reason: 'the self-updater downloads and installs an APK, which iOS '
            'cannot do. Leaving it enabled paints a red update badge on a '
            'fresh install and sends the user to a page of Android builds.',
      );
    });

    test('is false on macOS, which also cannot install an APK', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(BuildConfig.selfUpdateSupported, isFalse);
    });

    test('is true on Android for a github-distribution build', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // The default distribution is github, so this is the shipped case.
      expect(BuildConfig.isGithubBuild, isTrue);
      expect(BuildConfig.selfUpdateSupported, isTrue);
    });

    test('does not depend on remembering a build flag', () {
      // The bug this guards: DISTRIBUTION defaults to github, so any iOS
      // build that omits --dart-define=DISTRIBUTION=appStore used to inject
      // the real updater. The platform check must hold even then.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(BuildConfig.isGithubBuild, isTrue,
          reason: 'this test is only meaningful while github is the default');
      expect(BuildConfig.selfUpdateSupported, isFalse);
    });
  });
}
