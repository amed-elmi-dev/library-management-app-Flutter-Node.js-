import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:cached_network_image/cached_network_image.dart";
import "../../controllers/book_detail_controller.dart";
import "../../models/book.dart";
import "../../theme/app_theme.dart";

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final BookDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(BookDetailController(), tag: widget.bookId);
    _controller.fetchBook(widget.bookId);
  }

  @override
  void dispose() {
    Get.delete<BookDetailController>(tag: widget.bookId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Detail")),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.book.value == null) {
          return Center(
            child: Text(
              _controller.errorMessage.value.isEmpty
                  ? "No data available"
                  : _controller.errorMessage.value,
            ),
          );
        }

        final book = _controller.book.value!;
        final available = book.availableCopies > 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: "book-${book.id}",
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: book.coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.book,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : const Icon(
                          Icons.book,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                book.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(book.author, style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text("Available: ${book.availableCopies}")),
                  Chip(label: Text("Total: ${book.totalCopies}")),
                ],
              ),
              const SizedBox(height: 12),
              Text(book.description.isEmpty ? "No description" : book.description),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: available
                          ? () async {
                              final ok = await _controller.borrow();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? "Borrowed successfully"
                                        : "Something went wrong. Please try again.",
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Borrow"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: !available
                          ? () async {
                              final ok = await _controller.reserve();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? "Reservation created"
                                        : "Something went wrong. Please try again.",
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Reserve"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
