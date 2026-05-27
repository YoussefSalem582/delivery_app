import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../config/environment/env_config.dart';
import '../network/api_endpoints.dart';
import '../network/mock_api_interceptor.dart';

/// Dio wrapper with locale header and logging interceptors.
class ApiClient {
  ApiClient({required Talker talker}) : _talker = talker {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      MockApiInterceptor(),
      TalkerDioLogger(
        talker: _talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseHeaders: false,
        ),
      ),
    ]);
  }

  final Talker _talker;
  late final Dio _dio;
  String _locale = 'en';

  Dio get dio => _dio;

  void setLocale(String languageCode) {
    _locale = languageCode;
    _dio.options.headers['Accept-Language'] = languageCode;
  }

  String get locale => _locale;

  bool get enableLogging => EnvConfig.enableLogging;
}

/// Legacy factory — prefer [ApiClient] via GetIt.
Dio createDioClient(Talker talker) => ApiClient(talker: talker).dio;
