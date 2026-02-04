import "dart:async";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:cached_network_image/cached_network_image.dart";
import "../../controllers/book_controller.dart";
import "../../models/book.dart";
import "../../theme/app_theme.dart";
import "book_detail_screen.dart";

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _controller = Get.put(BookController());
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _controller.updateSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
        actions: [
          IconButton(
            tooltip: "Filters",
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
          PopupMenuButton<String>(
            tooltip: "Sort",
            onSelected: (value) {
              // Placeholder for sorting logic.
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "title", child: Text("Title")),
              PopupMenuItem(value: "author", child: Text("Author")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search books",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.books.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.books.isEmpty) {
                return Center(
                  child: Text(
                    _controller.errorMessage.value.isEmpty
                        ? "No data available"
                        : _controller.errorMessage.value,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _controller.fetchBooks(reset: true),
                child: ListView.builder(
                  itemCount: _controller.books.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _controller.books.length) {
                      if (_controller.hasMore.value) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: TextButton(
                              onPressed: () => _controller.fetchBooks(),
                              child: const Text("Load more"),
                            ),
                          ),
                        );
                      }
                      return const SizedBox(height: 24);
                    }

                    final book = _controller.books[index];
                    return _BookCard(book: book);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text("Author"),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(hintText: "Author name"),
              ),
              const SizedBox(height: 12),
              const Text("Availability"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text("Available only"),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final available = book.availableCopies > 0;
    final badgeColor = available ? AppTheme.success : AppTheme.accent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "book-${book.id}",
              child: SizedBox(
                width: 54,
                height: 72,
                child: book.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.book,
                          size: 36,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : const Icon(
                        Icons.book,
                        size: 36,
                        color: AppTheme.textSecondary,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          available ? "Available" : "Unavailable",
                          style: TextStyle(color: badgeColor, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Get.to(() => BookDetailScreen(bookId: book.id));
                        },
                        child: const Text("View"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
