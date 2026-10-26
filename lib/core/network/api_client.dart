import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/storage_service.dart';

/// Cliente HTTP centralizado que gestiona timeouts, headers y tokens.
class ApiClient {
  final Dio dio;
  final StorageService? storageService;

  ApiClient({Dio? customDio, this.storageService, String? baseUrl})
    : dio =
          customDio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: {'Accept': 'application/json'},
            ),
          ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Si no se incluyó header de autorización y tenemos storage, adjuntar token guardado
          if (!options.headers.containsKey('Authorization') &&
              storageService != null) {
            final token = await storageService!.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );
  }
}
