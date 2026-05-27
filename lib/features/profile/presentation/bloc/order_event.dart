part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderLoadRequested extends OrderEvent {
  const OrderLoadRequested();
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
  const OrderLoaded(this.orders);
  final List<OrderEntity> orders;
  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  const OrderError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
