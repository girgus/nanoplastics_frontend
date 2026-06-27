import 'package:mocktail/mocktail.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/services/digest_service.dart';

/// Test double for DigestService. Override only the methods your test needs.
/// Unoverridden methods throw `UnimplementedError` via Fake, revealing gaps.
class FakeDigestService extends Fake implements DigestService {
  /// Saved papers. Defaults to empty.
  List<DigestPaper> papers = [];

  /// Export text. Defaults to null.
  String? exportText;

  /// Whether add/remove operations succeed. Defaults to true.
  bool operationsSucceed = true;

  /// Records paper IDs added to tresor.
  final List<String> addedToTresor = [];

  /// Records paper IDs removed from tresor.
  final List<String> removedFromTresor = [];

  /// Tresor IDs set. Updated by add/removeFromTresor.
  final Set<String> _tresorIds = {};

  @override
  Future<List<DigestPaper>> fetchSavedPapers() async => papers;

  @override
  Future<String?> exportTresor() async => exportText;

  @override
  Future<bool> addToTresor(String paperId) async {
    if (operationsSucceed) {
      addedToTresor.add(paperId);
      _tresorIds.add(paperId);
    }
    return operationsSucceed;
  }

  @override
  Future<bool> removeFromTresor(String paperId) async {
    if (operationsSucceed) {
      removedFromTresor.add(paperId);
      _tresorIds.remove(paperId);
    }
    return operationsSucceed;
  }

  @override
  List<String> getKeywords() => [];

  @override
  Set<String> get tresorIds => Set.unmodifiable(_tresorIds);

  @override
  Future<void> syncUser() async {}

  @override
  Future<List<String>> getTresorIds({String? email}) async =>
      tresorIds.toList();

  @override
  Future<List<DigestPaper>> fetchLatest({
    DateTime? since,
    List<String>? keywords,
  }) async =>
      [];

  @override
  Future<bool> updatePreferences({
    bool? enabled,
    int? digestHour,
    List<String>? keywords,
  }) async =>
      true;

  @override
  Future<void> updateFcmToken(String token) async {}
}
