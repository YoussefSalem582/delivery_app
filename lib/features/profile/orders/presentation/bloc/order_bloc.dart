import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/profile/shared/domain/usecases/order_usecases.dart';

part 'order_event.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required GetCachedOrdersUseCase getCachedOrders,
    required GetOrdersUseCase getOrders,
    required RefreshOrdersUseCase refreshOrders,
    required NetworkStatus networkStatus,
  })  : _getCachedOrders = getCachedOrders,
        _getOrders = getOrders,
        _refreshOrders = refreshOrders,
        _networkStatus = networkStatus,
        super(const OrderInitial()) {
    on<OrderLoadRequested>(_onLoad);
    on<OrderRefreshRequested>(_onRefresh);
  }

  final GetCachedOrdersUseCase _getCachedOrders;
  final GetOrdersUseCase _getOrders;
  final RefreshOrdersUseCase _refreshOrders;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    final isOffline = !(await _networkStatus.isOnline);
    final cachedResult = await _getCachedOrders(const NoParams());
    cachedResult.fold(
      (_) {},
      (cached) {
        if (cached.isNotEmpty) {
          emit(OrderLoaded(orders: cached, isOffline: isOffline));
        }
      },
    );
    final result = await _getOrders(const NoParams());
    result.fold(
      (Failure failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrderLoaded(orders: orders, isOffline: isOffline)),
    );
  }

  Future<void> _onRefresh(
    OrderRefreshRequested event,
    Emitter<OrderState> emit,
  ) async {
    final current = state;
    if (current is OrderLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    final result = await _refreshOrders(const NoParams());
    final isOffline = !(await _networkStatus.isOnline);
    result.fold(
      (Failure failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrderLoaded(orders: orders, isOffline: isOffline)),
    );
  }
}
