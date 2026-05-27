import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class RegisterUseCase extends UseCase<UserEntity, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    try {
      final user = await _repository.register(
        name: params.name,
        email: params.email,
        password: params.password,
      );
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
