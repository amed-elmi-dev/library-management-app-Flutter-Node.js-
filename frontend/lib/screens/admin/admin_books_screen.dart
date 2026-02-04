import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/admin_controller.dart";

class AdminBooksScreen extends StatelessWidget {
  const AdminBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Books")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.books.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        return ListView.builder(
          itemCount: controller.books.length,
          itemBuilder: (context, index) {
            final book = controller.books[index];
            return ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showBookDialog(context, controller, book),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.deleteBook(book.id),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _showBookDialog(
    BuildContext context,
    AdminController controller, [
    dynamic book,
  ]) {
    final titleController = TextEditingController(text: book?.title ?? "");
    final authorController = TextEditingController(text: book?.author ?? "");
    final categoryController = TextEditingController(text: book?.category ?? "");
    final totalCopiesController =
        TextEditingController(text: book?.totalCopies?.toString() ?? "1");
    final descriptionController =
        TextEditingController(text: book?.description ?? "");
    final coverController = TextEditingController(text: book?.coverUrl ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book == null ? "Add Book" : "Edit Book"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: "Author"),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: totalCopiesController,
                  decoration: const InputDecoration(labelText: "Total Copies"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: coverController,
                  decoration: const InputDecoration(labelText: "Cover URL"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final data = {
                  "title": titleController.text,
                  "author": authorController.text,
                  "category": categoryController.text,
                  "totalCopies": int.tryParse(totalCopiesController.text) ?? 1,
                  "description": descriptionController.text,
                  "coverUrl": coverController.text,
                };
                if (book == null) {
                  controller.createBook(data);
                } else {
                  controller.updateBook(book.id, data);
                }
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
