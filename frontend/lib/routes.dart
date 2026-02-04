import "package:get/get.dart";
import "screens/auth/login_screen.dart";
import "screens/auth/register_screen.dart";
import "screens/splash_screen.dart";
import "screens/main/main_screen.dart";
import "screens/admin/admin_dashboard.dart";
import "screens/settings/settings_screen.dart";

class AppRoutes {
  static const String splash = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  static const String admin = "/admin";
  static const String settings = "/settings";
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
  ];
}
