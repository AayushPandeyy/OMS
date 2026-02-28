class FoodItem {
  final String foodId;
  final String foodName;
  final String categoryId;
  final double price;
  final bool isAvailable;

  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.categoryId,
    required this.price,
    this.isAvailable = true,
  });

  FoodItem copyWith({
    String? foodId,
    String? foodName,
    String? categoryId,
    double? price,
    bool? isAvailable,
  }) {
    return FoodItem(
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'categoryId': categoryId,
      'price': price,
      'isAvailable': isAvailable,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
