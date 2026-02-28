import 'package:oms/features/table_management/domain/enums/table_status.dart';

class TableInfo {
  final String tableNumber;
  final int capacity;
  final TableStatus status;
  final String? currentOrder;

  TableInfo({
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.currentOrder,
  });
}