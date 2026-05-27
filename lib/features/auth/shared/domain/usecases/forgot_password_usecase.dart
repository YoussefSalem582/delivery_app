import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordParams extends Equatable {
  const ForgotPasswordParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordUseCase extends UseCase<void, ForgotPasswordParams> {
  ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    try {
      await _repository.requestPasswordReset(email: params.email);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
