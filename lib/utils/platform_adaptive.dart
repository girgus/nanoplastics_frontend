import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlatformAdaptive {
  static bool get isWeb => kIsWeb;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 768;
  }

  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Require both large width and sufficient height: landscape phones can exceed
    // 1100dp wide at 1× density but are still phone-form-factor devices.
    return size.width >= 1100 && size.height >= 768;
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
