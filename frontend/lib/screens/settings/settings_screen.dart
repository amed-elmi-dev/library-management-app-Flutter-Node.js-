import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/settings_controller.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleTheme,
              ),
              ListTile(
                title: const Text("Clear cached data"),
                subtitle: const Text("Remove locally stored book list"),
                trailing: const Icon(Icons.delete_outline),
                onTap: () async {
                  await controller.clearCache();
                  Get.snackbar("Success", "Cache cleared");
                },
              ),
              const SizedBox(height: 20),
              const Text("App Version: 1.0.0"),
            ],
          );
        }),
      ),
    );
  }
}
