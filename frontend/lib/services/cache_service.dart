import "package:shared_preferences/shared_preferences.dart";

class CacheService {
  CacheService._internal();

  static final CacheService instance = CacheService._internal();
  static const String _booksCacheKey = "cached_books";

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _ensureInit() {
    if (_prefs == null) {
      throw StateError("CacheService not initialized");
    }
  }

  Future<void> cacheBooksJson(String json) async {
    _ensureInit();
    await _prefs!.setString(_booksCacheKey, json);
  }

  String? getCachedBooksJson() {
    _ensureInit();
    return _prefs!.getString(_booksCacheKey);
  }

  Future<void> clearBooksCache() async {
    _ensureInit();
    await _prefs!.remove(_booksCacheKey);
  }
}
