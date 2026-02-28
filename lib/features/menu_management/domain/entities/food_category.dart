class FoodCategory {
  final String categoryId;
  final String categoryName;
  final String cafeId;

  FoodCategory({
    required this.categoryId,
    required this.categoryName,
    required this.cafeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'cafeId': cafeId,
    };
  }

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      cafeId: json['cafeId'] as String,
    );
  }
}
