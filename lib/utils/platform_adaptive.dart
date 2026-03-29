import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformAdaptive {
  static bool get isWeb => kIsWeb;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 768;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1100;
  }

  static double contentMaxWidth(
    BuildContext context, {
    double mobile = 720,
    double tablet = 1040,
    double desktop = 1440,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static Future<bool> launchExternalUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) {
    return launchExternalUri(
      Uri.parse(url),
      mode: mode,
    );
  }

  static Future<bool> launchExternalUri(
    Uri uri, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) {
    return launchUrl(
      uri,
      mode: mode,
      webOnlyWindowName: '_blank',
    );
  }
}
