import "package:get/get.dart";
import "../routes.dart";
import "../services/api_service.dart";
import "../services/storage_service.dart";

class AuthController extends GetxController {
  AuthController({StorageService? storageService, ApiService? apiService})
      : _storageService = storageService ?? StorageService.instance,
        _apiService = apiService ?? ApiService.instance;

  final StorageService _storageService;
  final ApiService _apiService;

  Future<void> verifyAuth() async {
    final token = await _storageService.readToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      await _apiService.getCurrentUser();
      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      await _storageService.clearToken();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
