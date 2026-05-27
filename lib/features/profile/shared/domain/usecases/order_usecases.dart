import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    try {
      final orders = await _repository.getOrders();
      return Right(orders);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class RefreshOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  RefreshOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    try {
      final orders = await _repository.getOrders(forceRefresh: true);
      return Right(orders);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class GetCachedOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  GetCachedOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return Right(_repository.getCachedOrders());
  }
}
