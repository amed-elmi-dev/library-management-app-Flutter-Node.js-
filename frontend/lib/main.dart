import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:shared_preferences/shared_preferences.dart";
import "routes.dart";
import "services/cache_service.dart";
import "theme/app_theme.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.instance.init();
  final prefs = await SharedPreferences.getInstance();
  final themeSetting = prefs.getString("theme_mode") ?? "system";
  final initialThemeMode = themeSetting == "dark"
      ? ThemeMode.dark
      : themeSetting == "light"
          ? ThemeMode.light
          : ThemeMode.system;

  runApp(LibraryApp(initialThemeMode: initialThemeMode));
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Library Management",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
