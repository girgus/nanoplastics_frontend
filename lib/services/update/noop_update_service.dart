import 'update_service_api.dart';

/// No-op update service for Play Store and App Store builds.
///
/// The OS-level store owns updates on those channels, so every method
/// here returns a safe "nothing to do" answer. Callers that still reach
/// into this service (because they forgot to check [isEnabled] first)
/// get predictable idle state, never a crash.
class NoOpUpdateService implements UpdateServiceApi {
  @override
  bool get isEnabled => false;

  @override
  UpdateState get currentState => UpdateState.idle;

  @override
  double get downloadProgress => 0.0;

  @override
  bool get isPaused => false;

  @override
  void addStateListener(Function(UpdateState, double) callback) {
    // Mirror GithubUpdateService contract: fire once on subscribe so UI
    // gets a deterministic initial state without a special-case branch.
    callback(UpdateState.idle, 0.0);
  }

  @override
  void removeStateListener(Function(UpdateState, double) callback) {}

  @override
  void pauseDownload() {}

  @override
  void resumeDownload() {}

  @override
  void cancelDownload() {}

  @override
  Future<bool> checkForUpdates({bool force = false}) async => false;

  @override
  Future<bool> checkInstallationComplete() async => false;

  @override
  Future<bool> startUpdate() async => false;

  @override
  Future<bool> retryInstallation() async => false;
}
