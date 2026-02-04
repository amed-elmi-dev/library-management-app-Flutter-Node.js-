import "package:dio/dio.dart";
import "package:get/get.dart" hide Response;
import "../config/app_config.dart";
import "../routes.dart";
import "storage_service.dart";

class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await StorageService.instance.clearToken();
            if (Get.currentRoute != AppRoutes.login) {
              Get.offAllNamed(AppRoutes.login);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }

  Future<Response<T>> getCurrentUser<T>() {
    return _dio.get<T>("/users/me");
  }

  Future<Response<T>> login<T>({
    required String email,
    required String password,
  }) {
    return _dio.post<T>(
      "/auth/login",
      data: {"email": email, "password": password},
    );
  }

  Future<Response<T>> register<T>({
    required String name,
    required String email,
    required String password,
  }) {
    return _dio.post<T>(
      "/auth/register",
      data: {"name": name, "email": email, "password": password},
    );
  }

  Future<Response<T>> getBookById<T>(String id) {
    return _dio.get<T>("/books/$id");
  }

  Future<Response<T>> borrowBook<T>(String bookId) {
    return _dio.post<T>("/borrows/borrow", data: {"bookId": bookId});
  }

  Future<Response<T>> reserveBook<T>(String bookId) {
    return _dio.post<T>("/reservations", data: {"bookId": bookId});
  }

  Future<Response<T>> getMyBorrows<T>() {
    return _dio.get<T>("/borrows/me");
  }

  Future<Response<T>> returnBorrow<T>(String borrowId) {
    return _dio.post<T>("/borrows/$borrowId/return");
  }

  Future<Response<T>> getMyReservations<T>() {
    return _dio.get<T>("/reservations/me");
  }

  Future<Response<T>> cancelReservation<T>(String reservationId) {
    return _dio.delete<T>("/reservations/$reservationId");
  }

  Future<Response<T>> updateProfile<T>({
    required String name,
    required String email,
  }) {
    return _dio.put<T>("/users/me", data: {"name": name, "email": email});
  }

  Future<Response<T>> getAllBooks<T>() {
    return _dio.get<T>("/books");
  }

  Future<Response<T>> createBook<T>(Map<String, dynamic> data) {
    return _dio.post<T>("/books", data: data);
  }

  Future<Response<T>> updateBook<T>(String id, Map<String, dynamic> data) {
    return _dio.put<T>("/books/$id", data: data);
  }

  Future<Response<T>> deleteBook<T>(String id) {
    return _dio.delete<T>("/books/$id");
  }

  Future<Response<T>> getUsers<T>() {
    return _dio.get<T>("/users");
  }

  Future<Response<T>> getAllBorrows<T>() {
    return _dio.get<T>("/borrows");
  }
}

