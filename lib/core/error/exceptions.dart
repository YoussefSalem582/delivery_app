import 'package:delivery_app/core/error/failures.dart';

/// Data-layer exception mapped to [Failure] in repositories.
class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  @override
  String toString() => message;
}

Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;
  if (error is AppException) {
    return ServerFailure(
      message: error.message,
      statusCode: error.statusCode,
      errors: error.errors,
    );
  }
  return UnexpectedFailure(message: error.toString());
}
