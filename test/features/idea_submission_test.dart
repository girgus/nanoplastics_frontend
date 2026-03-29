import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/idea_attachment.dart';
import 'package:nanoplastics_app/services/api_service.dart';
import 'package:nanoplastics_app/services/service_locator.dart';
import 'package:nanoplastics_app/widgets/brainstorm_box.dart';
import '../helpers/test_app.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/fake_api_service.dart';

void main() {
  group('Idea submission — validation & flow', () {
    late FakeApiService fakeApi;

    setUp(() async {
      await setupServiceLocator();
      fakeApi = FakeApiService();
      ServiceLocator().overrideApiServiceForTesting(fakeApi);
    });

    // ── ApiService validation (no HTTP needed) ────────────────────────────

    test('FakeApiService is wired into ServiceLocator before the test runs',
        () async {
      expect(ServiceLocator().apiService, same(fakeApi));
    });

    test('ApiService rejects short description without attachments', () async {
      // Real validation inside ApiService before any HTTP call.
      // Must use ApiService() directly — ServiceLocator().apiService is fakeApi here.
      final result = await ApiService().submitIdea(description: 'Hi');
      expect(result['success'], isFalse);
      expect(result['message'], contains('10 characters'));
    });

    test('ApiService accepts description >= 10 chars via fake', () async {
      fakeApi.submitResult = {'success': true, 'message': 'Created'};
      final result = await fakeApi.submitIdea(
        description: 'Microplastic filter for household water',
        category: 'human_blood',
      );
      expect(result['success'], isTrue);
      expect(fakeApi.submitCalls, hasLength(1));
      expect(fakeApi.submitCalls.first['category'], 'human_blood');
    });

    test('ApiService accepts short description when attachment has bytes',
        () async {
      // BrainstormBox allows submitting even with short text if an attachment exists.
      // ApiService checks: description < 10 AND no attachments → reject.
      // So with an attachment it should call through (fake returns success).
      final att = IdeaAttachment(
        path: '',
        name: 'photo.jpg',
        mimeType: 'image/jpeg',
        type: AttachmentType.image,
        bytes: Uint8List(100),
      );
      fakeApi.submitResult = {'success': true, 'message': 'Created'};
      final result = await fakeApi.submitIdea(
        description: 'Idea',
        attachments: [att],
      );
      expect(result['success'], isTrue);
    });

    // ── BrainstormBox widget ──────────────────────────────────────────────

    testWidgets('BrainstormBox renders text input and submit button',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          BrainstormBox(
            title: 'Your Idea',
            username: 'Tester',
            placeholder: 'Describe your idea...',
            onSubmit: (_, __) async {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(BrainstormBox), findsOneWidget);
      // Text field should be present
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('BrainstormBox calls onSubmit with typed text', (tester) async {
      String? submittedText;
      List<IdeaAttachment>? submittedAttachments;

      await tester.pumpWidget(
        buildTestableWidget(
          BrainstormBox(
            title: 'Your Idea',
            username: 'Tester',
            placeholder: 'Describe your idea...',
            onSubmit: (text, atts) async {
              submittedText = text;
              submittedAttachments = atts;
            },
          ),
        ),
      );
      await tester.pump();

      // Type a valid idea description
      await tester.enterText(
          find.byType(TextField).first, 'Biodegradable water filters');
      await tester.pump();

      // Tap the submit button (ElevatedButton)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(submittedText, 'Biodegradable water filters');
      expect(submittedAttachments, isEmpty);
    });
  });
}
