/// Conditional facade: returns a Turnstile token on web, null on mobile.
///
/// Mobile clients have no Origin header so the backend skips Turnstile
/// verification for them — this stub is the no-op path.
library;

export 'turnstile_stub.dart' if (dart.library.html) 'turnstile_web.dart';
