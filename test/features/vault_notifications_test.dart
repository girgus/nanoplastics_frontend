import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import 'package:nanoplastics_app/services/push_notification_service.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_digest_service.dart';

void main() {
  group('VaultScreen — push notification saves', () {
    late FakeDigestService fakeDigest;

    setUp(() async {
      await setupServiceLocator();
      fakeDigest = FakeDigestService();
      DigestService.overrideForTesting(fakeDigest);
    });

    tearDown(() {
      DigestService.overrideForTesting(null);
      PushNotificationService.onPaperOpen = null;
    });

    test('4 notification taps add 4 papers to tresor', () async {
      final paperIds = ['paper_1', 'paper_2', 'paper_3', 'paper_4'];

      // Set up callback
      PushNotificationService.onPaperOpen = (id) {
        fakeDigest.addToTresor(id);
      };

      // Fire 4 paper open events
      for (final id in paperIds) {
        PushNotificationService.onPaperOpen?.call(id);
      }

      // All 4 should be in addedToTresor
      expect(fakeDigest.addedToTresor, paperIds);
    });

    test('notifications fail when operationsSucceed is false', () async {
      fakeDigest.operationsSucceed = false;
      const paperIds = ['paper_1', 'paper_2'];

      PushNotificationService.onPaperOpen = (id) {
        fakeDigest.addToTresor(id);
      };

      for (final id in paperIds) {
        PushNotificationService.onPaperOpen?.call(id);
      }

      // None should be in addedToTresor (operations failed)
      expect(fakeDigest.addedToTresor, isEmpty);
    });

    test('mixed success/failure: first 2 succeed, last 2 fail', () async {
      PushNotificationService.onPaperOpen = (id) {
        fakeDigest.addToTresor(id);
      };

      // Start with success
      fakeDigest.operationsSucceed = true;
      PushNotificationService.onPaperOpen?.call('paper_1');
      PushNotificationService.onPaperOpen?.call('paper_2');

      // Switch to failure
      fakeDigest.operationsSucceed = false;
      PushNotificationService.onPaperOpen?.call('paper_3');
      PushNotificationService.onPaperOpen?.call('paper_4');

      // Only first 2 in added list
      expect(fakeDigest.addedToTresor, ['paper_1', 'paper_2']);
    });
  });
}
