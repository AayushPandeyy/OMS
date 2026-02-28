// Restaurant Types
enum RestaurantType { CAFE, RESTAURANT, FAST_FOOD, CLOUD_KITCHEN }

// Cuisine Types
enum CuisineType { INDIAN, CHINESE, ITALIAN, NEPALI }

// Order Types
enum OrderType { DINE_IN, DELIVERY, TAKEAWAY }

// Tax Types
enum TaxType { TAX, VAT, GST, SERVICE_FEE }

// Plan Types
enum PlanType { STARTER, BASIC, PREMIUM, ENTERPRISE }

// Optional: Extension to get string value (matching Django)
extension EnumToString on Enum {
  String get value => toString().split('.').last;

  String get label {
    final parts = value.split('_');
    return parts
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
