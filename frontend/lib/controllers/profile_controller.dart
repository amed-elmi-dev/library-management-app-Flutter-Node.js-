import "package:get/get.dart";
import "../models/user.dart";
import "../routes.dart";
import "../services/api_service.dart";
import "../services/storage_service.dart";

class ProfileController extends GetxController {
  ProfileController({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService.instance,
        _storageService = storageService ?? StorageService.instance;

  final ApiService _apiService;
  final StorageService _storageService;

  final user = Rxn<User>();
  final isLoading = false.obs;
  final errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.getCurrentUser<Map<String, dynamic>>();
      final payload = response.data ?? {};
      final userData = payload["user"] ?? payload;
      if (userData is Map<String, dynamic>) {
        user.value = User.fromJson(userData);
      } else {
        user.value = null;
      }
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      await _apiService.updateProfile(name: name, email: email);
      await fetchProfile();
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    Get.offAllNamed(AppRoutes.login);
  }
}
