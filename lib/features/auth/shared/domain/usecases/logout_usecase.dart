import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await _repository.logout();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
