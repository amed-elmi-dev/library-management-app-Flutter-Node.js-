import "package:get/get.dart";
import "../models/book.dart";
import "../models/user.dart";
import "../services/api_service.dart";

class AdminController extends GetxController {
  AdminController({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  final isAdmin = false.obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;

  final totalBooks = 0.obs;
  final totalUsers = 0.obs;
  final totalBorrows = 0.obs;

  final books = <Book>[].obs;
  final users = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    verifyAdmin();
  }

  Future<void> verifyAdmin() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.getCurrentUser<Map<String, dynamic>>();
      final payload = response.data ?? {};
      final userData = payload["user"] ?? payload;
      final role = userData is Map<String, dynamic>
          ? userData["role"]?.toString()
          : null;
      isAdmin.value = role == "admin";
      if (isAdmin.value) {
        await fetchOverview();
      }
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOverview() async {
    await Future.wait([
      fetchBooks(),
      fetchUsers(),
      fetchBorrows(),
    ]);
  }

  Future<void> fetchBooks() async {
    try {
      final response = await _apiService.getAllBooks<List<dynamic>>();
      final data = response.data ?? [];
      final list = data
          .map((item) => Book.fromJson(item as Map<String, dynamic>))
          .toList();
      books.assignAll(list);
      totalBooks.value = list.length;
    } catch (_) {
      // keep existing values
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await _apiService.getUsers<List<dynamic>>();
      final data = response.data ?? [];
      final list = data
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
      users.assignAll(list);
      totalUsers.value = list.length;
    } catch (_) {
      // keep existing values
    }
  }

  Future<void> fetchBorrows() async {
    try {
      final response = await _apiService.getAllBorrows<List<dynamic>>();
      final data = response.data ?? [];
      totalBorrows.value = data.length;
    } catch (_) {
      // keep existing values
    }
  }

  Future<void> createBook(Map<String, dynamic> data) async {
    try {
      await _apiService.createBook(data);
      await fetchBooks();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    try {
      await _apiService.updateBook(id, data);
      await fetchBooks();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _apiService.deleteBook(id);
      await fetchBooks();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }
}
