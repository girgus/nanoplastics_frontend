import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('CategoryDetailDataFactory', () {
    test('all factories produce entries and evidence sections', () {
      final allCategories = CategoryDetailDataFactory.all(l10n);

      expect(allCategories.length, equals(12));

      for (final data in allCategories) {
        expect(data.title.isNotEmpty, isTrue, reason: 'missing title');
        expect(data.subtitle.isNotEmpty, isTrue,
            reason: '${data.categoryKey} subtitle');
        expect(data.entries, isNotEmpty, reason: '${data.categoryKey} entries');
        expect(
          data.evidenceSections,
          isNotEmpty,
          reason: '${data.categoryKey} evidence sections',
        );
        expect(
          data.evidenceStudyCount > 0,
          isTrue,
          reason: '${data.categoryKey} evidence count',
        );
      }
    });

    test('evidence sections contain valid metadata and non-empty URLs', () {
      for (final data in CategoryDetailDataFactory.all(l10n)) {
        for (final section in data.evidenceSections) {
          expect(section.title.trim().isNotEmpty, isTrue,
              reason: '${data.categoryKey} section title');
          expect(section.studies, isNotEmpty,
              reason: '${data.categoryKey}/${section.id} studies');

          for (final study in section.studies) {
            expect(study.title.trim().isNotEmpty, isTrue,
                reason: '${data.categoryKey}/${section.id} study title');
            expect(study.authorsShort.trim().isNotEmpty, isTrue,
                reason: '${data.categoryKey}/${section.id} authors');
            expect(study.journal.trim().isNotEmpty, isTrue,
                reason: '${data.categoryKey}/${section.id} journal');
            expect(study.url.trim().isNotEmpty, isTrue,
                reason: '${data.categoryKey}/${section.id} url');
          }
        }
      }
    });

    test('legacy sourceLinks remain populated from evidence data', () {
      for (final data in CategoryDetailDataFactory.all(l10n)) {
        expect(data.sourceLinks, isNotNull,
            reason: '${data.categoryKey} sourceLinks');
        expect(
          data.sourceLinks!.length,
          equals(data.evidenceStudyCount),
          reason: '${data.categoryKey} legacy sourceLinks count',
        );
      }
    });

    test('entries keep valid PDF page ranges', () {
      for (final data in CategoryDetailDataFactory.all(l10n)) {
        for (final entry in data.entries) {
          if (entry.pdfStartPage != null && entry.pdfEndPage != null) {
            expect(
              entry.pdfStartPage! <= entry.pdfEndPage!,
              isTrue,
              reason:
                  '${data.title} -> ${entry.highlight}: start ${entry.pdfStartPage} > end ${entry.pdfEndPage}',
            );
          }
        }
      }
    });
  });

  group('EvidenceStudy', () {
    test('tags default to empty list', () {
      const study = EvidenceStudy(
        title: 'Test',
        authorsShort: 'Author et al.',
        journal: 'Journal',
        year: 2025,
        url: 'https://example.com',
      );

      expect(study.tags, isEmpty);
    });
  });
}
