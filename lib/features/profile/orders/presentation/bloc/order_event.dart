part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderLoadRequested extends OrderEvent {
  const OrderLoadRequested();
}

class OrderRefreshRequested extends OrderEvent {
  const OrderRefreshRequested();
}

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  const OrderLoaded({
    required this.orders,
    this.isOffline = false,
    this.isRefreshing = false,
  });

  final List<OrderEntity> orders;
  final bool isOffline;
  final bool isRefreshing;

  OrderLoaded copyWith({
    List<OrderEntity>? orders,
    bool? isOffline,
    bool? isRefreshing,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [orders, isOffline, isRefreshing];
}

class OrderError extends OrderState {
  const OrderError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
