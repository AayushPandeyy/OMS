import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oms/features/table_management/domain/enums/table_status.dart';
import 'package:oms/features/table_management/domain/entities/table_info.dart';
import 'package:oms/features/orders/presentation/pages/new_order_page.dart';

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({Key? key}) : super(key: key);

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  String? selectedTable;
  String filterStatus = 'All';

  // Sample table data
  final List<TableInfo> tables = [
    TableInfo(tableNumber: '1', capacity: 2, status: TableStatus.available),
    TableInfo(
      tableNumber: '2',
      capacity: 4,
      status: TableStatus.occupied,
      currentOrder: '#124',
    ),
    TableInfo(tableNumber: '3', capacity: 2, status: TableStatus.available),
    TableInfo(tableNumber: '4', capacity: 6, status: TableStatus.reserved),
    TableInfo(tableNumber: '5', capacity: 4, status: TableStatus.available),
    TableInfo(
      tableNumber: '6',
      capacity: 2,
      status: TableStatus.occupied,
      currentOrder: '#125',
    ),
    TableInfo(tableNumber: '7', capacity: 4, status: TableStatus.available),
    TableInfo(tableNumber: '8', capacity: 8, status: TableStatus.available),
    TableInfo(tableNumber: '9', capacity: 2, status: TableStatus.available),
    TableInfo(
      tableNumber: '10',
      capacity: 4,
      status: TableStatus.occupied,
      currentOrder: '#126',
    ),
    TableInfo(tableNumber: '11', capacity: 2, status: TableStatus.available),
    TableInfo(tableNumber: '12', capacity: 6, status: TableStatus.available),
    TableInfo(tableNumber: '13', capacity: 4, status: TableStatus.reserved),
    TableInfo(tableNumber: '14', capacity: 2, status: TableStatus.available),
    TableInfo(tableNumber: '15', capacity: 4, status: TableStatus.available),
  ];

  List<TableInfo> get filteredTables {
    if (filterStatus == 'All') return tables;

    switch (filterStatus) {
      case 'Available':
        return tables.where((t) => t.status == TableStatus.available).toList();
      case 'Occupied':
        return tables.where((t) => t.status == TableStatus.occupied).toList();
      case 'Reserved':
        return tables.where((t) => t.status == TableStatus.reserved).toList();
      default:
        return tables;
    }
  }

  int get availableCount =>
      tables.where((t) => t.status == TableStatus.available).length;
  int get occupiedCount =>
      tables.where((t) => t.status == TableStatus.occupied).length;
  int get reservedCount =>
      tables.where((t) => t.status == TableStatus.reserved).length;

  Color getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }

  String getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }

  void confirmTableSelection() {
    if (selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a table'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final table = tables.firstWhere((t) => t.tableNumber == selectedTable);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderPage(tableNumber: table.tableNumber),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Table ${table.tableNumber} selected'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Table',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(),

          // Filter Chips
          _buildFilterChips(),

          // Table Grid
          Expanded(
            child: filteredTables.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_bar_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tables found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];
                      return _buildTableCard(table);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: selectedTable != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: confirmTableSelection,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm Table $selectedTable',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Available',
              availableCount.toString(),
              Colors.green,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Occupied',
              occupiedCount.toString(),
              Colors.red,
              Icons.person,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Reserved',
              reservedCount.toString(),
              Colors.orange,
              Icons.bookmark_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Available', 'Occupied', 'Reserved'];

    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          bool isSelected = filterStatus == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  filterStatus = filter;
                  // Clear selection if filtered out
                  if (selectedTable != null) {
                    final table = tables.firstWhere(
                      (t) => t.tableNumber == selectedTable,
                    );
                    if (!filteredTables.contains(table)) {
                      selectedTable = null;
                    }
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCard(TableInfo table) {
    bool isSelected = selectedTable == table.tableNumber;
    bool isAvailable = table.status == TableStatus.available;
    Color statusColor = getStatusColor(table.status);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTable = table.tableNumber;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status badge at top
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Table number - large and centered
                  Row(
                    children: [
                      Text(
                        table.tableNumber,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                          height: 1,
                        ),
                      ),
                      Icon(
                        Icons.table_restaurant,
                        size: 24,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status text
                  Text(
                    getStatusText(table.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : statusColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Current order if exists
                  if (table.currentOrder != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      table.currentOrder!,
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
