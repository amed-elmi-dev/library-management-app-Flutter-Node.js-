import "package:get/get.dart";
import "../models/reservation.dart";
import "../services/api_service.dart";

class ReservationController extends GetxController {
  ReservationController({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  final reservations = <Reservation>[].obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.getMyReservations<List<dynamic>>();
      final data = response.data ?? [];
      final list = data
          .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
          .toList();
      reservations.assignAll(list);
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelReservation(String id) async {
    try {
      await _apiService.cancelReservation(id);
      await fetchReservations();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }
}
