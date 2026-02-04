import "package:get/get.dart";
import "../models/borrow.dart";
import "../services/api_service.dart";

class BorrowController extends GetxController {
  BorrowController({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  final activeBorrows = <Borrow>[].obs;
  final returnedBorrows = <Borrow>[].obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchBorrows();
  }

  Future<void> fetchBorrows() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.getMyBorrows<List<dynamic>>();
      final data = response.data ?? [];
      final borrows = data
          .map((item) => Borrow.fromJson(item as Map<String, dynamic>))
          .toList();

      activeBorrows.assignAll(
        borrows.where((b) => b.status == "active").toList(),
      );
      returnedBorrows.assignAll(
        borrows.where((b) => b.status == "returned").toList(),
      );
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> returnBorrow(String borrowId) async {
    try {
      await _apiService.returnBorrow(borrowId);
      await fetchBorrows();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }
}
