import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oms/features/auth/presentation/pages/login_page.dart';
import 'package:oms/features/orders/presentation/pages/table_selection_page.dart';
import 'package:oms/features/menu_management/presentation/pages/add_food_category_page.dart';
import 'package:oms/features/menu_management/presentation/pages/add_food_item_page.dart';
import 'package:oms/features/staff_management/presentation/pages/add_staff_page.dart';
import 'package:oms/features/table_management/presentation/pages/add_new_table_page.dart';
import 'package:oms/features/table_management/domain/entities/table_info.dart';
import 'package:oms/features/table_management/domain/enums/table_status.dart';
import 'package:oms/services/auth_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool showKitchenView = false;
  bool isFabExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  final List<TableInfo> tables = [
    TableInfo(
      tableNumber: 'Table 1',
      capacity: 4,
      status: TableStatus.available,
    ),
    TableInfo(
      tableNumber: 'Table 2',
      capacity: 2,
      status: TableStatus.occupied,
      currentOrder: '#201',
    ),
    TableInfo(
      tableNumber: 'Table 3',
      capacity: 6,
      status: TableStatus.reserved,
    ),
    TableInfo(
      tableNumber: 'Table 4',
      capacity: 4,
      status: TableStatus.occupied,
      currentOrder: '#202',
    ),
    TableInfo(
      tableNumber: 'Table 5',
      capacity: 2,
      status: TableStatus.available,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      isFabExpanded = !isFabExpanded;
      if (isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.clearTokens();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OMS Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Refresh logic here
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shift Info at top
                  _buildShiftInfo(),

                  // Today's Status Cards
                  _buildStatusCards(),

                  // Quick Actions
                  _buildQuickActions(),

                  // Kitchen View Toggle
                  _buildKitchenToggle(),

                  // Live Orders or Kitchen Status
                  showKitchenView ? _buildKitchenStatus() : _buildLiveOrders(),

                  // Tables (slidable view)
                  _buildTablesSection(),

                  // // Inventory Alerts
                  // _buildInventoryAlerts(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Backdrop when expanded
          if (isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),
          // Expanded menu items
          if (isFabExpanded)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildExpandedMenuItems(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomOrderBar(),
    );
  }

  Widget _buildShiftInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waiter - Aayush',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Shift: 9:00 AM - 5:00 PM',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Logout')),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Active Orders',
                  value: '8',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.restaurant_outlined,
                  label: 'In Kitchen',
                  value: '3',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '24',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.warning_amber_outlined,
                  label: 'Low Stock',
                  value: '5',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to detailed view
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionButton(
                icon: Icons.food_bank,
                label: 'Add Food Category',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFoodCategoryPage(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.restaurant_menu,
                label: 'Add Food Item',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFoodItemPage(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.people_sharp,
                label: 'Add Staff',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddStaffPage(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.table_restaurant,
                label: 'Add New Table',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewTablePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Kitchen View',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: showKitchenView,
            onChanged: (value) {
              setState(() {
                showKitchenView = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOrders() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildOrderTile(
            orderNo: '#124',
            table: 'Table 5',
            type: 'Dine-in',
            status: 'Preparing',
            statusColor: Colors.orange,
            time: '12 min',
          ),
          const SizedBox(height: 12),
          _buildOrderTile(
            orderNo: '#125',
            table: 'Table 3',
            type: 'Dine-in',
            status: 'Ready',
            statusColor: Colors.blue,
            time: '5 min',
          ),
          const SizedBox(height: 12),
          _buildOrderTile(
            orderNo: '#126',
            table: 'Takeaway',
            type: 'Takeaway',
            status: 'Served',
            statusColor: Colors.green,
            time: '2 min',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile({
    required String orderNo,
    required String table,
    required String type,
    required String status,
    required Color statusColor,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$table • $type',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Mark Served'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenStatus() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kitchen Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildKitchenStatusTile(
            orderNo: '#124',
            status: 'Ready',
            icon: Icons.restaurant,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildKitchenStatusTile(
            orderNo: '#125',
            status: 'Delayed',
            icon: Icons.schedule,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildKitchenStatusTile(
            orderNo: '#126',
            status: 'In Progress',
            icon: Icons.hourglass_empty,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTablesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tables',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tables.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final t = tables[index];
              return Slidable(
                key: ValueKey(t.tableNumber),
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('View ${t.tableNumber}')),
                        );
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.visibility,
                      label: 'View',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('New order for ${t.tableNumber}'),
                          ),
                        );
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      icon: Icons.add,
                      label: 'New Order',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        setState(() {
                          // toggle to available
                          tables[index] = TableInfo(
                            tableNumber: t.tableNumber,
                            capacity: t.capacity,
                            status: TableStatus.available,
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${t.tableNumber} marked available'),
                          ),
                        );
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: 'Mark Free',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        setState(() {
                          tables[index] = TableInfo(
                            tableNumber: t.tableNumber,
                            capacity: t.capacity,
                            status: TableStatus.reserved,
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${t.tableNumber} reserved')),
                        );
                      },
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      icon: Icons.event,
                      label: 'Reserve',
                    ),
                  ],
                ),
                child: _buildTableTile(t),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableTile(TableInfo t) {
    final color = _statusToColor(t.status);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.table_restaurant, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.tableNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Capacity: ${t.capacity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusToText(t.status),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusToColor(TableStatus s) {
    switch (s) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }

  String _statusToText(TableStatus s) {
    switch (s) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }

  Widget _buildKitchenStatusTile({
    required String orderNo,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $orderNo',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(status, style: TextStyle(color: color, fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildInventoryAlerts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInventoryItem(
            item: 'Milk',
            status: 'Low Stock',
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildInventoryItem(
            item: 'Chicken',
            status: 'Out of Stock',
            icon: Icons.cancel,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          _buildInventoryItem(
            item: 'Tomatoes',
            status: 'Low Stock',
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem({
    required String item,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOrderBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: InkWell(
            onTap: _toggleFab,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      isFabExpanded ? Icons.close : Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isFabExpanded ? 'Close Menu' : 'New Order',
                      key: ValueKey<bool>(isFabExpanded),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandedMenuItems() {
    return [
      _buildBottomMenuItem(
        icon: Icons.table_restaurant,
        label: 'Dine-in',
        color: Colors.blue,
        offset: 0,
        onTap: () {
          _toggleFab();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TableSelectionPage()),
          );
        },
      ),
      _buildBottomMenuItem(
        icon: Icons.shopping_bag_outlined,
        label: 'Takeaway',
        color: Colors.orange,
        offset: 1,
        onTap: () {
          _toggleFab();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TableSelectionPage()),
          );
        },
      ),
      _buildBottomMenuItem(
        icon: Icons.delivery_dining,
        label: 'Delivery',
        color: Colors.green,
        offset: 2,
        onTap: () {
          _toggleFab();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TableSelectionPage()),
          );
        },
      ),
    ];
  }

  Widget _buildBottomMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required int offset,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
