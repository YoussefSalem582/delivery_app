import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/features/profile/presentation/bloc/order_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

void main() {
  late MockOrderRepository orderRepository;
  late MockNetworkStatus networkStatus;

  setUp(() {
    orderRepository = MockOrderRepository();
    networkStatus = MockNetworkStatus();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
  });

  group('OrderBloc', () {
    final orders = [
      OrderEntity(
        id: 'order-1',
        title: 'Test order',
        amount: 25,
        status: OrderStatus.pending,
        createdAt: DateTime(2026, 5, 1),
      ),
    ];

    final cachedOrders = [
      OrderEntity(
        id: 'cached',
        title: orders.first.title,
        amount: orders.first.amount,
        status: orders.first.status,
        createdAt: orders.first.createdAt,
      ),
    ];
    final freshOrders = [
      OrderEntity(
        id: 'fresh',
        title: orders.first.title,
        amount: orders.first.amount,
        status: orders.first.status,
        createdAt: orders.first.createdAt,
      ),
    ];

    blocTest<OrderBloc, OrderState>(
      'emits cached orders then refreshed list when data differs',
      build: () {
        when(() => orderRepository.getCachedOrders()).thenReturn(cachedOrders);
        when(() => orderRepository.getOrders()).thenAnswer((_) async => freshOrders);
        return OrderBloc(orderRepository, networkStatus);
      },
      act: (bloc) => bloc.add(const OrderLoadRequested()),
      expect: () => [
        const OrderLoading(),
        OrderLoaded(orders: cachedOrders, isOffline: false),
        OrderLoaded(orders: freshOrders, isOffline: false),
      ],
    );
  });
}
