import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/admin_controller.dart";

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: Obx(() {
        if (controller.users.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : "U"),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Text(user.role),
            );
          },
        );
      }),
    );
  }
}
