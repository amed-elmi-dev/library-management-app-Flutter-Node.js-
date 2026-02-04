import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/admin_controller.dart";
import "../../theme/app_theme.dart";
import "admin_books_screen.dart";
import "admin_users_screen.dart";

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isAdmin.value) {
          return const Center(child: Text("Access denied"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _StatCard(
                  label: "Books",
                  value: controller.totalBooks.value.toString(),
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: "Users",
                  value: controller.totalUsers.value.toString(),
                  color: AppTheme.secondary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: "Borrows",
                  value: controller.totalBorrows.value.toString(),
                  color: AppTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Manage Books"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const AdminBooksScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text("Manage Users"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const AdminUsersScreen()),
            ),
          ],
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
