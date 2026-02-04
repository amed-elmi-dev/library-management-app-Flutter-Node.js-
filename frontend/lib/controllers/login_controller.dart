import "package:get/get.dart";
import "../routes.dart";
import "../services/api_service.dart";
import "../services/storage_service.dart";

class LoginController extends GetxController {
  LoginController({StorageService? storageService, ApiService? apiService})
      : _storageService = storageService ?? StorageService.instance,
        _apiService = apiService ?? ApiService.instance;

  final StorageService _storageService;
  final ApiService _apiService;

  final isLoading = false.obs;
  final errorMessage = "".obs;

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r"^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final response = await _apiService.login(
        email: email.trim(),
        password: password,
      );

      final data = response.data as Map<String, dynamic>;
      final token = data["token"]?.toString();
      if (token == null || token.isEmpty) {
        throw Exception("Missing token");
      }

      await _storageService.writeToken(token);
      await _apiService.getCurrentUser();
      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }
}
