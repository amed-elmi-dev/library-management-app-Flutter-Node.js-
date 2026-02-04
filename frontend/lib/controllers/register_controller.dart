import "package:get/get.dart";
import "../routes.dart";
import "../services/api_service.dart";

class RegisterController extends GetxController {
  RegisterController({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  final isLoading = false.obs;
  final errorMessage = "".obs;

  String? validateName(String value) {
    if (value.isEmpty) {
      return "Full name is required";
    }
    return null;
  }

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

  String? validateConfirmPassword(String value, String original) {
    if (value.isEmpty) {
      return "Confirm your password";
    }
    if (value != original) {
      return "Passwords do not match";
    }
    return null;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = "";

    try {
      await _apiService.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      Get.offAllNamed(AppRoutes.login, arguments: {"registered": true});
    } catch (error) {
      errorMessage.value = "Something went wrong. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }
}
