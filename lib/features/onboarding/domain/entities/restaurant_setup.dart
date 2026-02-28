import 'package:oms/features/onboarding/domain/entities/tax_configuration.dart';

class RestaurantSetupRequest {
  final String name;
  final String logoUrl;
  final String restaurantType;
  final List<String> cuisineTypes;
  final String addressUrl;
  final String openingTime;
  final String closingTime;
  final List<String> openDays;
  final List<String> orderTypes;
  final int totalTables;
  final bool isTaxed;
  final String planType;
  final List<TaxConfiguration> taxConfigurations;

  const RestaurantSetupRequest({
    required this.name,
    required this.logoUrl,
    required this.restaurantType,
    required this.cuisineTypes,
    required this.addressUrl,
    required this.openingTime,
    required this.closingTime,
    required this.openDays,
    required this.orderTypes,
    required this.totalTables,
    required this.isTaxed,
    required this.planType,
    required this.taxConfigurations,
  });
}

class RestaurantSetupResponse {
  final String id;
  final String name;
  final String logoUrl;
  final String restaurantType;
  final List<String> cuisineTypes;
  final String addressUrl;
  final String openingTime;
  final String closingTime;
  final List<String> openDays;
  final List<String> orderTypes;
  final int totalTables;
  final bool isTaxed;
  final String planType;
  final List<TaxConfiguration> taxConfigurations;

  const RestaurantSetupResponse({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.restaurantType,
    required this.cuisineTypes,
    required this.addressUrl,
    required this.openingTime,
    required this.closingTime,
    required this.openDays,
    required this.orderTypes,
    required this.totalTables,
    required this.isTaxed,
    required this.planType,
    required this.taxConfigurations,
  });
}
