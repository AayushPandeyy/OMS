class MenuItem {
  final String name;
  final String category;
  final double price;
  final bool available;

  MenuItem({
    required this.name,
    required this.category,
    required this.price,
    this.available = true,
  });
}