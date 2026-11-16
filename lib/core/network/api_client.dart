import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';

/// Fournit le jeton d'authentification (Firebase ID token) a joindre aux requetes FastAPI.
typedef TokenProvider = Future<String?> Function();

/// Client HTTP vers l'API FastAPI. Convertit les erreurs Dio en [AppException].
class ApiClient {
  ApiClient({required String baseUrl, TokenProvider? tokenProvider, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 30),
              headers: {'Accept': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.call();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) => _guard(() => _dio.get<T>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? data}) => _guard(() => _dio.post<T>(path, data: data));

  Future<T> patch<T>(String path, {Object? data}) => _guard(() => _dio.patch<T>(path, data: data));

  Future<T> delete<T>(String path) => _guard(() => _dio.delete<T>(path));

  Future<T> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      final r = await call();
      return r.data as T;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  static AppException mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(e.message);
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final detail = _detail(e.response?.data);
        if (code == 401 || code == 403) return UnauthorizedException(detail);
        if (code == 404) return NotFoundException(detail);
        if (code == 422 || code == 400) return ValidationException('invalid', detail);
        return ServerException(statusCode: code, details: detail);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return e.error is AppException ? e.error! as AppException : NetworkException(e.message);
    }
  }

  /// FastAPI renvoie {"detail": "..."} ou une liste d'erreurs de validation.
  static String? _detail(Object? data) {
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return data?.toString();
  }
}

/// Jeton d'authentification courant, fourni par la feature auth (surcharge dans main()).
final authTokenProvider = Provider<TokenProvider>((ref) => () async => null);

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(baseUrl: config.apiBaseUrl, tokenProvider: ref.watch(authTokenProvider));
});
