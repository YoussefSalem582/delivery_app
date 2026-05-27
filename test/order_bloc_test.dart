import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/profile/orders/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/profile/shared/domain/usecases/order_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCachedOrdersUseCase extends Mock implements GetCachedOrdersUseCase {}

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class MockRefreshOrdersUseCase extends Mock implements RefreshOrdersUseCase {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

void main() {
  late MockGetCachedOrdersUseCase getCachedOrders;
  late MockGetOrdersUseCase getOrders;
  late MockRefreshOrdersUseCase refreshOrders;
  late MockNetworkStatus networkStatus;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getCachedOrders = MockGetCachedOrdersUseCase();
    getOrders = MockGetOrdersUseCase();
    refreshOrders = MockRefreshOrdersUseCase();
    networkStatus = MockNetworkStatus();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
  });

  OrderBloc buildBloc() => OrderBloc(
        getCachedOrders: getCachedOrders,
        getOrders: getOrders,
        refreshOrders: refreshOrders,
        networkStatus: networkStatus,
      );

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
        when(() => getCachedOrders(any()))
            .thenAnswer((_) async => Right(cachedOrders));
        when(() => getOrders(any())).thenAnswer((_) async => Right(freshOrders));
        return buildBloc();
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
