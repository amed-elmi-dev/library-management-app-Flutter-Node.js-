import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../services/cache_service.dart";

class SettingsController extends GetxController {
  SettingsController({CacheService? cacheService})
      : _cacheService = cacheService ?? CacheService.instance;

  final CacheService _cacheService;

  final isDarkMode = false.obs;

  static const String _themeKey = "theme_mode";

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey) ?? "system";
    isDarkMode.value = value == "dark";
  }

  Future<void> toggleTheme(bool enabled) async {
    isDarkMode.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, enabled ? "dark" : "light");
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> clearCache() async {
    await _cacheService.clearBooksCache();
  }
}
