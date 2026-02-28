class RestaurantTable {
  final String tableId;
  final String nameOrNumber;
  final int capacity;
  final String cafeId;

  RestaurantTable({
    required this.tableId,
    required this.nameOrNumber,
    required this.capacity,
    required this.cafeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'nameOrNumber': nameOrNumber,
      'capacity': capacity,
      'cafeId': cafeId,
    };
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      tableId: json['tableId'] as String,
      nameOrNumber: json['nameOrNumber'] as String,
      capacity: json['capacity'] as int,
      cafeId: json['cafeId'] as String,
    );
  }
}
