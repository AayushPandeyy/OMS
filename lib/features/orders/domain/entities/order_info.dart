import 'package:oms/features/orders/domain/enums/order_status.dart';
import 'package:oms/features/orders/domain/enums/order_type.dart';
import 'package:oms/features/orders/domain/entities/order_item.dart';

class OrderInfo {
  final String orderNumber;
  final String? tableNumber;
  final OrderType orderType;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;
  final String time;
  final String? customerName;

  OrderInfo({
    required this.orderNumber,
    this.tableNumber,
    required this.orderType,
    required this.status,
    required this.items,
    required this.total,
    required this.time,
    this.customerName,
  });
}