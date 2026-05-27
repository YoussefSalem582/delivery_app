import 'package:delivery_app/core/architecture/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false});
  List<OrderEntity> getCachedOrders();
}
