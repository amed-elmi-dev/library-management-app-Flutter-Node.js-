import "package:get/get.dart";
import "../models/book.dart";
import "../services/api_service.dart";

class BookDetailController extends GetxController {
  BookDetailController({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  final book = Rxn<Book>();
  final isLoading = false.obs;
  final errorMessage = "".obs;

  Future<void> fetchBook(String id) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.getBookById<Map<String, dynamic>>(id);
      book.value = Book.fromJson(response.data ?? {});
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> borrow() async {
    final current = book.value;
    if (current == null) return false;
    try {
      await _apiService.borrowBook(current.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reserve() async {
    final current = book.value;
    if (current == null) return false;
    try {
      await _apiService.reserveBook(current.id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
