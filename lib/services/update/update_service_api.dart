import '../update_service.dart' show UpdateState;

export '../update_service.dart' show UpdateState;

/// Abstract update service — two implementations live behind it:
///
/// - [GithubUpdateService] (file: update_service.dart) — real self-update flow,
///   injected when `BuildConfig.isGithubBuild` is true.
/// - [NoOpUpdateService] — silent stub, injected for Play Store & App Store
///   builds where the OS-level store handles updates instead.
///
/// `ServiceLocator` picks at init based on `BuildConfig.distribution` so the
/// unused implementation is tree-shaken out of store bundles.
abstract class UpdateServiceApi {
  /// Whether self-update is available on this build channel.
  /// UI layer reads this to hide update buttons / badges when false.
  bool get isEnabled;

  UpdateState get currentState;
  double get downloadProgress;
  bool get isPaused;

  void addStateListener(Function(UpdateState, double) callback);
  void removeStateListener(Function(UpdateState, double) callback);

  void pauseDownload();
  void resumeDownload();
  void cancelDownload();

  Future<bool> checkForUpdates({bool force = false});
  Future<bool> checkInstallationComplete();
  Future<bool> startUpdate();
  Future<bool> retryInstallation();
}
