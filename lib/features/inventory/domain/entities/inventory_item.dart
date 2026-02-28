import 'package:oms/features/inventory/domain/enums/stock_status.dart';

class InventoryItem {
  final String name;
  final String category;
  final int currentStock;
  final int minStock;
  final int maxStock;
  final String unit;
  final StockStatus status;
  final DateTime? lastUpdated;

  InventoryItem({
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unit,
    required this.status,
    this.lastUpdated,
  });
}