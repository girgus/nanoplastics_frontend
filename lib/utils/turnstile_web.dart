import 'dart:js_interop';

/// Bridge to window.nanosolveTurnstile.requestToken() defined in web/index.html.
/// Returns the Cloudflare token, or null if the challenge failed.
@JS('nanosolveTurnstile.requestToken')
external JSPromise<JSAny?> _requestToken();

Future<String?> getTurnstileToken() async {
  try {
    final result = await _requestToken().toDart;
    if (result == null) return null;
    return (result as JSString).toDart;
  } catch (_) {
    return null;
  }
}
