import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';

part 'order_event.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc(this._repository, this._networkStatus)
      : super(const OrderInitial()) {
    on<OrderLoadRequested>(_onLoad);
    on<OrderRefreshRequested>(_onRefresh);
  }

  final OrderRepository _repository;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(const OrderLoading());
    final isOffline = !(await _networkStatus.isOnline);
    try {
      final cached = _repository.getCachedOrders();
      if (cached.isNotEmpty) {
        emit(OrderLoaded(orders: cached, isOffline: isOffline));
      }
      final orders = await _repository.getOrders();
      emit(OrderLoaded(orders: orders, isOffline: isOffline));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    OrderRefreshRequested event,
    Emitter<OrderState> emit,
  ) async {
    final current = state;
    if (current is OrderLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final orders = await _repository.getOrders(forceRefresh: true);
      final isOffline = !(await _networkStatus.isOnline);
      emit(OrderLoaded(orders: orders, isOffline: isOffline));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
