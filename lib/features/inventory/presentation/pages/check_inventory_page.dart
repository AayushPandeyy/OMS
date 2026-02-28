import 'package:flutter/material.dart';
import 'package:oms/features/inventory/domain/enums/stock_status.dart';
import 'package:oms/features/inventory/domain/entities/inventory_item.dart';

class CheckInventoryPage extends StatefulWidget {
  const CheckInventoryPage({Key? key}) : super(key: key);

  @override
  State<CheckInventoryPage> createState() => _CheckInventoryPageState();
}

class _CheckInventoryPageState extends State<CheckInventoryPage> {
  String selectedFilter = 'All';
  final TextEditingController searchController = TextEditingController();

  // Sample inventory data
  final List<InventoryItem> inventory = [
    InventoryItem(
      name: 'Chicken Breast',
      category: 'Meat',
      currentStock: 25,
      minStock: 20,
      maxStock: 100,
      unit: 'kg',
      status: StockStatus.inStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    InventoryItem(
      name: 'Milk',
      category: 'Dairy',
      currentStock: 8,
      minStock: 10,
      maxStock: 50,
      unit: 'L',
      status: StockStatus.lowStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    InventoryItem(
      name: 'Tomatoes',
      category: 'Vegetables',
      currentStock: 0,
      minStock: 15,
      maxStock: 50,
      unit: 'kg',
      status: StockStatus.outOfStock,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      name: 'Mozzarella Cheese',
      category: 'Dairy',
      currentStock: 12,
      minStock: 10,
      maxStock: 30,
      unit: 'kg',
      status: StockStatus.inStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    InventoryItem(
      name: 'Lettuce',
      category: 'Vegetables',
      currentStock: 5,
      minStock: 8,
      maxStock: 25,
      unit: 'kg',
      status: StockStatus.lowStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    InventoryItem(
      name: 'Olive Oil',
      category: 'Oils',
      currentStock: 0,
      minStock: 5,
      maxStock: 20,
      unit: 'L',
      status: StockStatus.outOfStock,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    InventoryItem(
      name: 'Pasta',
      category: 'Grains',
      currentStock: 45,
      minStock: 20,
      maxStock: 80,
      unit: 'kg',
      status: StockStatus.inStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    InventoryItem(
      name: 'Eggs',
      category: 'Dairy',
      currentStock: 120,
      minStock: 100,
      maxStock: 300,
      unit: 'pcs',
      status: StockStatus.inStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    InventoryItem(
      name: 'Onions',
      category: 'Vegetables',
      currentStock: 6,
      minStock: 10,
      maxStock: 40,
      unit: 'kg',
      status: StockStatus.lowStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    InventoryItem(
      name: 'Coca Cola',
      category: 'Beverages',
      currentStock: 48,
      minStock: 30,
      maxStock: 100,
      unit: 'cans',
      status: StockStatus.inStock,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<String> get categories {
    Set<String> cats = {'All'};
    for (var item in inventory) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  List<InventoryItem> get filteredInventory {
    var items = inventory;

    // Filter by status
    if (selectedFilter == 'Low Stock') {
      items = items
          .where((item) => item.status == StockStatus.lowStock)
          .toList();
    } else if (selectedFilter == 'Out of Stock') {
      items = items
          .where((item) => item.status == StockStatus.outOfStock)
          .toList();
    } else if (selectedFilter == 'In Stock') {
      items = items
          .where((item) => item.status == StockStatus.inStock)
          .toList();
    } else if (selectedFilter != 'All') {
      // Filter by category
      items = items.where((item) => item.category == selectedFilter).toList();
    }

    // Filter by search
    if (searchController.text.isNotEmpty) {
      items = items
          .where(
            (item) => item.name.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return items;
  }

  int get inStockCount =>
      inventory.where((item) => item.status == StockStatus.inStock).length;
  int get lowStockCount =>
      inventory.where((item) => item.status == StockStatus.lowStock).length;
  int get outOfStockCount =>
      inventory.where((item) => item.status == StockStatus.outOfStock).length;

  Color getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  String getStatusText(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  double getStockPercentage(InventoryItem item) {
    if (item.maxStock == 0) return 0;
    return (item.currentStock / item.maxStock) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Export inventory
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            // Status Summary
            _buildStatusSummary(),

            // Search Bar
            _buildSearchBar(),

            // Filter Chips
            _buildFilterChips(),

            // Inventory List
            Expanded(
              child: filteredInventory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredInventory.length,
                      itemBuilder: (context, index) {
                        final item = filteredInventory[index];
                        return _buildInventoryCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'In Stock',
              inStockCount,
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Low Stock',
              lowStockCount,
              Colors.orange,
              Icons.warning_amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Out of Stock',
              outOfStockCount,
              Colors.red,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search inventory...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'In Stock',
      'Low Stock',
      'Out of Stock',
      ...categories.skip(1),
    ];

    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          bool isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
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

  Widget _buildInventoryCard(InventoryItem item) {
    double percentage = getStockPercentage(item);
    Color statusColor = getStatusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        size: 24,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusText(item.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stock Info
                Row(
                  children: [
                    Expanded(
                      child: _buildStockInfo(
                        'Current',
                        '${item.currentStock} ${item.unit}',
                        statusColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStockInfo(
                        'Min',
                        '${item.minStock} ${item.unit}',
                        Colors.grey[600]!,
                      ),
                    ),
                    Expanded(
                      child: _buildStockInfo(
                        'Max',
                        '${item.maxStock} ${item.unit}',
                        Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock Level',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Last Updated
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Updated ${_getTimeAgo(item.lastUpdated)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateStockDialog(item, false),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showUpdateStockDialog(item, true),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add Stock'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showUpdateStockDialog(InventoryItem item, bool isAdding) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? 'Add Stock' : 'Remove Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Stock: ${item.currentStock} ${item.unit}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (${item.unit})',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  isAdding ? Icons.add : Icons.remove,
                  color: isAdding ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (quantityController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAdding
                          ? 'Added ${quantityController.text} ${item.unit} to ${item.name}'
                          : 'Removed ${quantityController.text} ${item.unit} from ${item.name}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdding
                  ? Theme.of(context).colorScheme.primary
                  : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isAdding ? 'Add' : 'Remove'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
