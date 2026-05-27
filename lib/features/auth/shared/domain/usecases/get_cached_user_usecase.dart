import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCachedUserUseCase extends UseCase<UserEntity?, NoParams> {
  GetCachedUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    try {
      if (!_repository.isLoggedIn()) return const Right(null);
      final user = await _repository.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
