import "dart:convert";
import "package:get/get.dart";
import "../models/book.dart";
import "../services/api_service.dart";
import "../services/cache_service.dart";

class BookController extends GetxController {
  BookController({ApiService? apiService, CacheService? cacheService})
      : _apiService = apiService ?? ApiService.instance,
        _cacheService = cacheService ?? CacheService.instance;

  final ApiService _apiService;
  final CacheService _cacheService;

  final books = <Book>[].obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;
  final hasMore = true.obs;
  final page = 1.obs;
  final searchQuery = "".obs;

  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchBooks(reset: true);
  }

  Future<void> fetchBooks({bool reset = false}) async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    errorMessage.value = "";

    if (reset) {
      page.value = 1;
      hasMore.value = true;
      books.clear();
    }

    try {
      final response = await _apiService.get<List<dynamic>>(
        "/books",
        query: {
          "page": page.value,
          "limit": pageSize,
          if (searchQuery.value.isNotEmpty) "search": searchQuery.value,
        },
      );

      final data = response.data ?? [];
      final fetched = data
          .map((item) => Book.fromJson(item as Map<String, dynamic>))
          .toList();

      if (fetched.isEmpty) {
        hasMore.value = false;
      } else {
        books.addAll(fetched);
        page.value += 1;
      }

      await _cacheService.cacheBooksJson(jsonEncode(books.map((b) => b.toJson()).toList()));
    } catch (error) {
      final cached = _cacheService.getCachedBooksJson();
      if (cached != null) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        books.assignAll(decoded.map((item) => Book.fromJson(item as Map<String, dynamic>)));
        Get.snackbar("Notice", "Showing cached data");
      } else {
        errorMessage.value = "Something went wrong. Please try again.";
      }
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    fetchBooks(reset: true);
  }
}
