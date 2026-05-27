import 'package:hive/hive.dart';

enum OrderStatus {
  pending,
  inTransit,
  delivered,
}

class OrderEntity extends HiveObject {
  OrderEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
