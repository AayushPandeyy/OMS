import 'package:oms/features/orders/domain/entities/menu_item.dart';

class OrderItem {
  final MenuItem menuItem;
  int quantity;
  String? notes;

  OrderItem({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
  });
}