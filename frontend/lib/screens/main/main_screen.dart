import "package:flutter/material.dart";
import "package:get/get.dart";
import "../home/book_list_screen.dart";
import "../borrow/borrow_history_screen.dart";
import "../reservation/reservation_screen.dart";
import "../profile/profile_screen.dart";
import "../admin/admin_dashboard.dart";
import "../../controllers/navigation_controller.dart";
import "../../controllers/admin_controller.dart";

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NavigationController _navController = Get.put(NavigationController());
  final AdminController _adminController = Get.put(AdminController());

  List<Widget?> _cachedScreens = [];
  int _cacheCount = 0;

  List<Widget Function()> _builders(bool isAdmin) {
    return [
      () => const BookListScreen(),
      () => const ReservationScreen(),
      () => const BorrowHistoryScreen(),
      () => const ProfileScreen(),
      if (isAdmin) () => const AdminDashboardScreen(),
    ];
  }

  Widget _getScreen(int index, bool isAdmin) {
    final builders = _builders(isAdmin);
    if (_cacheCount != builders.length) {
      _cachedScreens = List<Widget?>.filled(builders.length, null);
      _cacheCount = builders.length;
    }

    _cachedScreens[index] ??= builders[index]();
    return _cachedScreens[index]!;
  }

  Future<bool> _onWillPop() async {
    if (_navController.selectedIndex.value != 0) {
      _navController.setIndex(0);
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit"),
          content: const Text("Do you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Exit"),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAdmin = _adminController.isAdmin.value;
      final builders = _builders(isAdmin);
      final index = _navController.selectedIndex.value;

      if (index >= builders.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navController.setIndex(0);
        });
      }

      final safeIndex = index >= builders.length ? 0 : index;

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: _getScreen(safeIndex, isAdmin),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: _navController.setIndex,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                label: "Reservations",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "Borrow History",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Profile",
              ),
              if (isAdmin)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: "Admin",
                ),
            ],
          ),
        ),
      );
    });
  }
}
