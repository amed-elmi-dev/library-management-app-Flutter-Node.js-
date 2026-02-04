import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:cached_network_image/cached_network_image.dart";
import "../../controllers/borrow_controller.dart";
import "../../theme/app_theme.dart";

class BorrowHistoryScreen extends StatelessWidget {
  const BorrowHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BorrowController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow History"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeBorrows.isEmpty && controller.returnedBorrows.isEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value.isEmpty
                  ? "No data available"
                  : controller.errorMessage.value,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBorrows,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.activeBorrows.isNotEmpty) ...[
                const Text(
                  "Active",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...controller.activeBorrows.map((borrow) {
                  return _BorrowCard(
                    title: borrow.book?.title ?? "Unknown",
                    coverUrl: borrow.book?.coverUrl ?? "",
                    borrowedAt: borrow.borrowedAt,
                    dueAt: borrow.dueAt,
                    status: "Active",
                    onReturn: () => controller.returnBorrow(borrow.id),
                    showReturn: true,
                  );
                }),
                const SizedBox(height: 16),
              ],
              if (controller.returnedBorrows.isNotEmpty) ...[
                const Text(
                  "Returned",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...controller.returnedBorrows.map((borrow) {
                  return _BorrowCard(
                    title: borrow.book?.title ?? "Unknown",
                    coverUrl: borrow.book?.coverUrl ?? "",
                    borrowedAt: borrow.borrowedAt,
                    dueAt: borrow.dueAt,
                    status: "Returned",
                    showReturn: false,
                  );
                }),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _BorrowCard extends StatelessWidget {
  const _BorrowCard({
    required this.title,
    required this.coverUrl,
    required this.borrowedAt,
    required this.dueAt,
    required this.status,
    this.showReturn = false,
    this.onReturn,
  });

  final String title;
  final String coverUrl;
  final DateTime? borrowedAt;
  final DateTime? dueAt;
  final String status;
  final bool showReturn;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 70,
              child: coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.book,
                        size: 32,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : const Icon(Icons.book, size: 32, color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Borrowed: ${_formatDate(borrowedAt)}",
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  Text(
                    "Due: ${_formatDate(dueAt)}",
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: status == "Active" ? AppTheme.success : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (showReturn)
              ElevatedButton(
                onPressed: onReturn,
                child: const Text("Return"),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day}/${date.month}/${date.year}";
  }
}
