import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';
import 'token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
/// ─────────────────────────────────────────────────────────────────
///  KDX Store — Dio HTTP Client
///
///  Automatically injects `Authorization: Bearer <token>` on every
///  request if the user is logged in.
///
///  Error handling maps Laravel JSON error responses to typed
///  exceptions that the BLoC layer can handle cleanly.
/// ─────────────────────────────────────────────────────────────────
class ApiClient {
  final Dio _dio;
  final TokenService _tokenService;

  ApiClient(this._dio, this._tokenService) {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        // ── Auto-inject Bearer token ──────────────────────────────
        onRequest: (options, handler) async {
          // API_KEY is not in use currently

          try {
            final prefs = await SharedPreferences.getInstance();
            final lang = prefs.getString('app_language') ?? 'ar';
            options.headers['Accept-Language'] = lang;
            options.headers['X-Firebase-Locale'] = lang; // Just in case it needs it
            options.headers['Cookie'] = 'locale=$lang';
          } catch (_) {}

          // Always try to attach the sanctum token first
          final sanctumToken = _tokenService.getSanctumToken();
          if (sanctumToken != null && sanctumToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $sanctumToken';
          }

          // In Firebase Native mode, we fetch the token directly from Firebase Auth
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            try {
              final token = await currentUser.getIdToken();
              if (token != null && token.isNotEmpty) {
                options.headers['X-Firebase-Token'] = token;
                
                // Fallback to Firebase token for authorization if Sanctum token is missing
                if (sanctumToken == null || sanctumToken.isEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
              }
            } catch (e) {
              // Ignore token fetch errors here
            }
          }
          return handler.next(options);
        },

        // ── Log responses in debug ────────────────────────────────
        onResponse: (response, handler) {
          return handler.next(response);
        },

        // ── Map HTTP errors to typed exceptions & handle retries ──
        onError: (DioException e, handler) async {
          // Check if we should retry (network issue or 503)
          final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.response != null && e.response!.statusCode == 503);

          final noRetry = e.requestOptions.extra['no-retry'] == true;

          if (isNetworkError && !noRetry) {
            int retries = 3;
            Duration delay = const Duration(seconds: 1);
            for (int i = 0; i < retries; i++) {
              await Future.delayed(delay);
              try {
                final options = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                  extra: {...e.requestOptions.extra, 'no-retry': true},
                );
                final response = await _dio.request(
                  e.requestOptions.path,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: options,
                );
                return handler.resolve(response);
              } on DioException catch (retryErr) {
                if (i == retries - 1) {
                  e = retryErr;
                }
                delay = delay * 2 +
                    Duration(
                        milliseconds: (delay.inMilliseconds * 0.1).toInt());
              }
            }
          }

          // Global 401 Unauthorized handling:
          if (e.response?.statusCode == 401) {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              try {
                // Clear the invalid Sanctum token
                await _tokenService.saveSanctumToken('');
                
                final token = await currentUser.getIdToken(true); // force refresh
                if (token != null && token.isNotEmpty) {
                  final name = currentUser.displayName ?? '';
                  final email = currentUser.email ?? '';
                  final provider = currentUser.providerData.isNotEmpty 
                      ? currentUser.providerData.first.providerId 
                      : 'google';
                  
                  // Lazily get AuthRemoteDataSource to avoid circular dependency
                  final authDataSource = GetIt.instance<AuthRemoteDataSource>();
                  final sanctumToken = await authDataSource.socialLogin(
                    provider: provider.contains('apple') ? 'apple' : 'google',
                    token: token,
                    name: name,
                    email: email,
                    firebaseUid: currentUser.uid,
                  );
                  
                  await _tokenService.saveSanctumToken(sanctumToken);
                  
                  // Retry the original failed request with the new token
                  final options = e.requestOptions;
                  options.headers['Authorization'] = 'Bearer $sanctumToken';
                  
                  final cloneDio = Dio();
                  cloneDio.options.baseUrl = options.baseUrl;
                  final response = await cloneDio.request(
                    options.path,
                    data: options.data,
                    queryParameters: options.queryParameters,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                    ),
                  );
                  return handler.resolve(response);
                }
              } catch (syncErr) {
                developer.log('Auto-sync failed on 401: $syncErr', name: 'ApiClient');
              }
            } else {
              // No Firebase user: they are a regular auth user and their session has expired.
              await _tokenService.clearAll();
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  // ── GET ───────────────────────────────────────────────────────────
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── POST ──────────────────────────────────────────────────────────
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Error Handler ─────────────────────────────────────────────────
  Exception _handleError(DioException e) {
    // Network / timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ConnectionException(
          message: 'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مجدداً.');
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Extract error message from Laravel JSON response
    String message = 'حدث خطأ غير متوقع';
    if (data is Map) {
      message = data['message']?.toString() ??
          data['error']?.toString() ??
          (data['errors'] as Map?)?.values.first?.first?.toString() ??
          message;
    }

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ServerException(
            message: 'ليس لديك صلاحية للوصول إلى هذه الصفحة.');
      case 404:
        return NotFoundException(message: message);
      case 422:
        // Laravel validation errors
        final errors = data is Map ? data['errors'] as Map? : null;
        final validationMsg =
            errors?.values.first?.first?.toString() ?? message;
        return ValidationException(
            message: validationMsg, errors: errors?.cast());
      case 429:
        return ServerException(
            message: 'طلبات كثيرة. يرجى الانتظار قليلاً ثم المحاولة.');
      case 500:
      case 503:
        developer.log('500 Error: $data');
        return ServerException(
            message: 'خطأ في الخادم. يرجى المحاولة لاحقاً. $message');
      default:
        return ServerException(message: message);
    }
  }
}
