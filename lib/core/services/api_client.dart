import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API Client Configuration & Service
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  // Change to your PHP server URL in production
  // Example: 'https://api.yourserver.com/api/v1'

  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Add JWT token to request headers
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  /// Handle successful responses
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    return handler.next(response);
  }

  /// Handle error responses
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - Token expired
    if (error.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      // Redirect to login (handled in app)
    }

    return handler.next(error);
  }

  // ==========================================
  // AUTHENTICATION ENDPOINTS
  // ==========================================

  /// User Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// User Registration
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'student' or 'teacher'
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get Current User
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // SUBJECT ENDPOINTS
  // ==========================================

  /// Get All Subjects
  Future<List<dynamic>> getSubjects({int classId = 1}) async {
    try {
      final response = await _dio.get(
        '/subjects',
        queryParameters: {'classId': classId},
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get Single Subject
  Future<Map<String, dynamic>> getSubject(int id) async {
    try {
      final response = await _dio.get('/subjects/$id');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create Subject (Teacher only)
  Future<Map<String, dynamic>> createSubject({
    required String name,
    required int classId,
    String? description,
    String color = '#5B5FDE',
    String icon = '📚',
  }) async {
    try {
      final response = await _dio.post(
        '/subjects',
        data: {
          'name': name,
          'classId': classId,
          'description': description,
          'color': color,
          'icon': icon,
        },
      );
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // TOPIC ENDPOINTS
  // ==========================================

  /// Get Topics for Subject
  Future<List<dynamic>> getTopics(int subjectId) async {
    try {
      final response = await _dio.get('/subjects/$subjectId/topics');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create Topic (Teacher only)
  Future<Map<String, dynamic>> createTopic({
    required int subjectId,
    required String title,
    String? description,
    int orderIndex = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/subjects/$subjectId/topics',
        data: {
          'title': title,
          'description': description,
          'orderIndex': orderIndex,
        },
      );
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // PROGRESS ENDPOINTS
  // ==========================================

  /// Get Student Progress
  Future<List<dynamic>> getProgress() async {
    try {
      final response = await _dio.get('/progress');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get Overall Progress
  Future<Map<String, dynamic>> getOverallProgress() async {
    try {
      final response = await _dio.get('/progress/overall');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update Topic Progress (Toggle completion)
  Future<Map<String, dynamic>> updateProgress(
    int topicId, {
    required bool isCompleted,
  }) async {
    try {
      final response = await _dio.put(
        '/progress/$topicId',
        data: {
          'isCompleted': isCompleted,
        },
      );
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // STUDENT ENDPOINTS (Teacher only)
  // ==========================================

  /// Get All Students in Class
  Future<List<dynamic>> getStudents() async {
    try {
      final response = await _dio.get('/students');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get Student Progress Details
  Future<List<dynamic>> getStudentProgress(int studentId) async {
    try {
      final response = await _dio.get('/students/$studentId/progress');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Save auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Clear auth token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }
}

// ==========================================
// CUSTOM API EXCEPTION
// ==========================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  /// Create from Dio Exception
  factory ApiException.fromDioException(DioException dioException) {
    String message = 'Unknown error occurred';
    int? statusCode = dioException.response?.statusCode;

    if (dioException.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (dioException.type == DioExceptionType.receiveTimeout) {
      message = 'Server response timeout';
    } else if (dioException.type == DioExceptionType.sendTimeout) {
      message = 'Request timeout';
    } else if (dioException.type == DioExceptionType.badResponse) {
      message = dioException.response?.data['message'] ?? 'Request failed';
      statusCode = dioException.response?.statusCode;
    } else if (dioException.type == DioExceptionType.unknown) {
      message = 'Network error';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      originalException: dioException,
    );
  }

  @override
  String toString() => message;
}

// ==========================================
// RIVERPOD PROVIDER FOR API CLIENT
// ==========================================

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
