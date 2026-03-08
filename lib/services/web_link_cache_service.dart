import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which web URLs the user has opened so we can show an
/// "available offline" indicator on source cards.
///
/// Actual offline caching is handled automatically by the platform WebView
/// (Android WebView / iOS WKWebView) HTTP disk cache.
class WebLinkCacheService {
  static const _kVisitedKey = 'web_link_visited_urls';

  WebLinkCacheService._();
  static final WebLinkCacheService _instance = WebLinkCacheService._();
  factory WebLinkCacheService() => _instance;

  Set<String>? _visited;

  Future<void> _load() async {
    if (_visited != null) return;
    final prefs = await SharedPreferences.getInstance();
    _visited = (prefs.getStringList(_kVisitedKey) ?? []).toSet();
  }

  Future<void> markVisited(String url) async {
    await _load();
    if (_visited!.contains(url)) return; // already saved
    _visited!.add(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kVisitedKey, _visited!.toList());
  }

  Future<bool> hasVisited(String url) async {
    await _load();
    return _visited!.contains(url);
  }
}
