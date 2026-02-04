import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/profile_controller.dart";
import "../../theme/app_theme.dart";
import "../../routes.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.user.value == null) {
          return Center(
            child: Text(
              controller.errorMessage.value.isEmpty
                  ? "No data available"
                  : controller.errorMessage.value,
            ),
          );
        }

        final user = controller.user.value!;
        final initials = user.name.isNotEmpty
            ? user.name.trim().split(" ").map((p) => p[0]).take(2).join()
            : "U";

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text("Role: ${user.role}", style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showEditDialog(context, controller, user),
                child: const Text("Edit Profile"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                ),
                child: const Text("Logout"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.settings),
                child: const Text("Settings"),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ProfileController controller,
    dynamic user,
  ) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateProfile(
                  name: nameController.text,
                  email: emailController.text,
                );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
