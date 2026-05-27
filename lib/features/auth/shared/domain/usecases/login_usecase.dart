import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    try {
      final user = await _repository.login(
        email: params.email,
        password: params.password,
      );
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
