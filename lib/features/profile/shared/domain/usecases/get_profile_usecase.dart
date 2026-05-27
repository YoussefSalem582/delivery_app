import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';

class GetProfileUseCase extends UseCase<UserEntity, NoParams> {
  GetProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    try {
      final user = await _repository.getProfile();
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class RefreshProfileParams {
  const RefreshProfileParams();
}

class RefreshProfileUseCase extends UseCase<UserEntity, RefreshProfileParams> {
  RefreshProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, UserEntity>> call(RefreshProfileParams params) async {
    try {
      final user = await _repository.getProfile(forceRefresh: true);
      return Right(user);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
