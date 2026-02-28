import 'package:flutter/material.dart';
import 'package:oms/features/orders/domain/enums/order_status.dart';
import 'package:oms/features/orders/domain/enums/order_type.dart';
import 'package:oms/features/orders/domain/entities/menu_item.dart';
import 'package:oms/features/orders/domain/entities/order_item.dart';

import 'package:oms/features/orders/domain/entities/order_info.dart' show OrderInfo;

class ViewOrdersPage extends StatefulWidget {
  const ViewOrdersPage({Key? key}) : super(key: key);

  @override
  State<ViewOrdersPage> createState() => _ViewOrdersPageState();
}

class _ViewOrdersPageState extends State<ViewOrdersPage> {
  String selectedFilter = 'All';

  // Sample orders data
  final List<OrderInfo> orders = [
    OrderInfo(
      orderNumber: '#124',
      tableNumber: 'Table 5',
      orderType: OrderType.dineIn,
      status: OrderStatus.preparing,
      items: [
        OrderItem(
          menuItem: MenuItem(
            name: 'Margherita Pizza',
            category: 'Pizza',
            price: 12.99,
          ),
          quantity: 2,
        ),
        OrderItem(
          menuItem: MenuItem(
            name: 'Coca Cola',
            category: 'Drinks',
            price: 2.99,
          ),
          quantity: 2,
        ),
      ],
      total: 31.96,
      time: '12 min ago',
    ),
    OrderInfo(
      orderNumber: '#125',
      tableNumber: 'Table 3',
      orderType: OrderType.dineIn,
      status: OrderStatus.ready,
      items: [
        OrderItem(
          menuItem: MenuItem(
            name: 'Chicken Burger',
            category: 'Burgers',
            price: 9.99,
          ),
          quantity: 1,
        ),
        OrderItem(
          menuItem: MenuItem(
            name: 'Caesar Salad',
            category: 'Salads',
            price: 7.99,
          ),
          quantity: 1,
        ),
      ],
      total: 17.98,
      time: '5 min ago',
    ),
    OrderInfo(
      orderNumber: '#126',
      orderType: OrderType.takeaway,
      status: OrderStatus.served,
      items: [
        OrderItem(
          menuItem: MenuItem(
            name: 'Pasta Carbonara',
            category: 'Pasta',
            price: 13.99,
          ),
          quantity: 3,
        ),
      ],
      total: 41.97,
      time: '2 min ago',
      customerName: 'John Doe',
    ),
    OrderInfo(
      orderNumber: '#127',
      tableNumber: 'Table 8',
      orderType: OrderType.dineIn,
      status: OrderStatus.pending,
      items: [
        OrderItem(
          menuItem: MenuItem(
            name: 'Beef Burger',
            category: 'Burgers',
            price: 11.99,
          ),
          quantity: 2,
        ),
        OrderItem(
          menuItem: MenuItem(
            name: 'Chicken Wings',
            category: 'Appetizers',
            price: 8.99,
          ),
          quantity: 1,
        ),
        OrderItem(
          menuItem: MenuItem(
            name: 'Orange Juice',
            category: 'Drinks',
            price: 3.99,
          ),
          quantity: 2,
        ),
      ],
      total: 40.95,
      time: '15 min ago',
    ),
    OrderInfo(
      orderNumber: '#128',
      orderType: OrderType.delivery,
      status: OrderStatus.preparing,
      items: [
        OrderItem(
          menuItem: MenuItem(
            name: 'Pepperoni Pizza',
            category: 'Pizza',
            price: 14.99,
          ),
          quantity: 1,
        ),
        OrderItem(
          menuItem: MenuItem(
            name: 'Greek Salad',
            category: 'Salads',
            price: 8.99,
          ),
          quantity: 1,
        ),
      ],
      total: 23.98,
      time: '8 min ago',
      customerName: 'Jane Smith',
    ),
  ];

  List<OrderInfo> get filteredOrders {
    if (selectedFilter == 'All') return orders;

    switch (selectedFilter) {
      case 'Pending':
        return orders.where((o) => o.status == OrderStatus.pending).toList();
      case 'Preparing':
        return orders.where((o) => o.status == OrderStatus.preparing).toList();
      case 'Ready':
        return orders.where((o) => o.status == OrderStatus.ready).toList();
      case 'Served':
        return orders.where((o) => o.status == OrderStatus.served).toList();
      default:
        return orders;
    }
  }

  int get pendingCount =>
      orders.where((o) => o.status == OrderStatus.pending).length;
  int get preparingCount =>
      orders.where((o) => o.status == OrderStatus.preparing).length;
  int get readyCount =>
      orders.where((o) => o.status == OrderStatus.ready).length;
  int get servedCount =>
      orders.where((o) => o.status == OrderStatus.served).length;

  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.served:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String getOrderTypeText(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine-in';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  IconData getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Advanced filter
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

            // Filter Tabs
            _buildFilterTabs(),

            // Orders List
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
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
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order);
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
            child: _buildSummaryItem('Pending', pendingCount, Colors.grey),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Preparing',
              preparingCount,
              Colors.orange,
            ),
          ),
          Expanded(child: _buildSummaryItem('Ready', readyCount, Colors.blue)),
          Expanded(
            child: _buildSummaryItem('Served', servedCount, Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Pending', 'Preparing', 'Ready', 'Served'];

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

  Widget _buildOrderCard(OrderInfo order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order Number and Type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            getOrderTypeIcon(order.orderType),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              order.tableNumber ??
                                  order.customerName ??
                                  getOrderTypeText(order.orderType),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusText(order.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Order Items
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.menuItem.name}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${(item.menuItem.price * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Time and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.visibility_outlined,
                          onTap: () => _showOrderDetails(order),
                        ),
                        const SizedBox(width: 8),
                        if (order.status != OrderStatus.served &&
                            order.status != OrderStatus.cancelled)
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            onTap: () {
                              // Edit order
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          if (order.status != OrderStatus.served &&
              order.status != OrderStatus.cancelled)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (order.status == OrderStatus.pending)
                      Expanded(
                        child: _buildStatusButton(
                          'Send to Kitchen',
                          Icons.restaurant,
                          () =>
                              _updateOrderStatus(order, OrderStatus.preparing),
                        ),
                      ),
                    if (order.status == OrderStatus.preparing) ...[
                      Expanded(
                        child: _buildStatusButton(
                          'Mark Ready',
                          Icons.check_circle_outline,
                          () => _updateOrderStatus(order, OrderStatus.ready),
                        ),
                      ),
                    ],
                    if (order.status == OrderStatus.ready)
                      Expanded(
                        child: _buildStatusButton(
                          'Mark Served',
                          Icons.done_all,
                          () => _updateOrderStatus(order, OrderStatus.served),
                        ),
                      ),
                    if (order.status != OrderStatus.ready) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusButton(
                          'Cancel',
                          Icons.cancel_outlined,
                          () =>
                              _updateOrderStatus(order, OrderStatus.cancelled),
                          isDestructive: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? Colors.red
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showOrderDetails(OrderInfo order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details ${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order Number', order.orderNumber),
                    _buildDetailRow('Type', getOrderTypeText(order.orderType)),
                    if (order.tableNumber != null)
                      _buildDetailRow('Table', order.tableNumber!),
                    if (order.customerName != null)
                      _buildDetailRow('Customer', order.customerName!),
                    _buildDetailRow('Status', getStatusText(order.status)),
                    _buildDetailRow('Time', order.time),
                    const SizedBox(height: 16),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.menuItem.name}',
                              ),
                            ),
                            Text(
                              '\$${(item.menuItem.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(OrderInfo order, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text(
          'Change order ${order.orderNumber} status to ${getStatusText(newStatus)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                // Update order status here
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Order ${order.orderNumber} marked as ${getStatusText(newStatus)}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
