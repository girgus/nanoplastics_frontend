package org.nanosolve.hive

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "org.nanosolve.hive/update"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getSdkVersion" -> {
          result.success(Build.VERSION.SDK_INT)
        }
        "hasInstallPermission" -> {
          // canRequestPackageInstalls() is the correct check for the user-controlled
          // "Install Unknown Apps" setting (available since API 26 / Android 8.0).
          // checkPermission(REQUEST_INSTALL_PACKAGES) always returns DENIED for
          // third-party apps because it is a signature/appop permission, not normal.
          val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
          } else {
            true
          }
          result.success(hasPermission)
        }
        else -> result.notImplemented()
      }
    }
  }
}