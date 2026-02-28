import 'package:flutter/material.dart';
import 'package:oms/features/orders/domain/entities/menu_item.dart';
import 'package:oms/features/orders/domain/entities/order_item.dart' show OrderItem;

class CreateOrderPage extends StatefulWidget {
  final String tableNumber;
  const CreateOrderPage({Key? key, required this.tableNumber})
    : super(key: key);

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  String selectedOrderType = 'Dine-in';
  String? selectedTable;
  String selectedCategory = 'All';
  List<OrderItem> cart = [];
  final TextEditingController searchController = TextEditingController();

  // Sample menu items
  final List<MenuItem> menuItems = [
    MenuItem(name: 'Margherita Pizza', category: 'Pizza', price: 12.99),
    MenuItem(name: 'Pepperoni Pizza', category: 'Pizza', price: 14.99),
    MenuItem(name: 'Chicken Burger', category: 'Burgers', price: 9.99),
    MenuItem(name: 'Beef Burger', category: 'Burgers', price: 11.99),
    MenuItem(name: 'Caesar Salad', category: 'Salads', price: 7.99),
    MenuItem(name: 'Greek Salad', category: 'Salads', price: 8.99),
    MenuItem(name: 'Coca Cola', category: 'Drinks', price: 2.99),
    MenuItem(name: 'Orange Juice', category: 'Drinks', price: 3.99),
    MenuItem(name: 'Pasta Carbonara', category: 'Pasta', price: 13.99),
    MenuItem(
      name: 'Chicken Wings',
      category: 'Appetizers',
      price: 8.99,
      available: false,
    ),
  ];

  List<String> get categories {
    Set<String> cats = {'All'};
    for (var item in menuItems) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  List<MenuItem> get filteredMenuItems {
    var items = menuItems;

    if (selectedCategory != 'All') {
      items = items.where((item) => item.category == selectedCategory).toList();
    }

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

  double get totalAmount {
    double total = 0;
    for (var item in cart) {
      total += item.menuItem.price * item.quantity;
    }
    return total;
  }

  void addToCart(MenuItem item) {
    setState(() {
      var existing = cart.firstWhere(
        (cartItem) => cartItem.menuItem.name == item.name,
        orElse: () => OrderItem(menuItem: item, quantity: 0),
      );

      if (existing.quantity == 0) {
        cart.add(OrderItem(menuItem: item));
      } else {
        existing.quantity++;
      }
    });
  }

  void removeFromCart(OrderItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return _buildCartItem(item);
                },
              ),
            ),
            _buildCartFooter(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Order Type Selection
          _buildOrderTypeSection(),

          // Search Bar
          _buildSearchBar(),

          // Category Filter
          _buildCategoryFilter(),

          // Menu Items
          Expanded(child: _buildMenuGrid()),
        ],
      ),
      bottomNavigationBar: cart.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildOrderTypeSection() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOrderTypeChip('Dine-in')),
              const SizedBox(width: 8),
              Expanded(child: _buildOrderTypeChip('Takeaway')),
              const SizedBox(width: 8),
              Expanded(child: _buildOrderTypeChip('Delivery')),
            ],
          ),
          if (selectedOrderType == 'Dine-in') ...[
            const SizedBox(height: 12),
            Text(
              'Table: ${widget.tableNumber}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderTypeChip(String type) {
    bool isSelected = selectedOrderType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOrderType = type;
          if (type != 'Dine-in') {
            selectedTable = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          hintText: 'Search menu items...',
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          bool isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
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

  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredMenuItems.length,
      itemBuilder: (context, index) {
        final item = filteredMenuItems[index];
        return _buildMenuItem(item);
      },
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    int quantity = cart
        .firstWhere(
          (cartItem) => cartItem.menuItem.name == item.name,
          orElse: () => OrderItem(menuItem: item, quantity: 0),
        )
        .quantity;

    return GestureDetector(
      onTap: item.available ? () => addToCart(item) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image placeholder
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: item.available ? Colors.grey[100] : Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Image(
                    image: NetworkImage(
                      "https://img.freepik.com/free-photo/top-view-table-full-food_23-2149209253.jpg?semt=ais_hybrid&w=740&q=80",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: item.available ? Colors.black87 : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: item.available
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          if (!item.available)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Out',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (quantity > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.menuItem.price.toStringAsFixed(2)} x ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    removeFromCart(item);
                  });
                  if (cart.isEmpty) {
                    Navigator.pop(context);
                  }
                },
                color: Theme.of(context).colorScheme.primary,
              ),
              Text(
                item.quantity.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    item.quantity++;
                  });
                },
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          Text(
            '\$${(item.menuItem.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter() {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmOrder();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.length} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: showCartBottomSheet,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'View Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder() {
    if (selectedOrderType == 'Dine-in' && selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a table'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Type: $selectedOrderType'),
            if (selectedTable != null) Text('Table: $selectedTable'),
            const SizedBox(height: 8),
            Text('Items: ${cart.length}'),
            Text(
              'Total: \$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order placed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Reset cart
              setState(() {
                cart.clear();
                selectedTable = null;
              });
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
