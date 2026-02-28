import 'package:oms/features/onboarding/data/models/tax_configuration_model.dart';
import 'package:oms/features/onboarding/domain/entities/restaurant_setup.dart';
import 'package:oms/features/onboarding/domain/entities/tax_configuration.dart';

class RestaurantSetupRequestModel extends RestaurantSetupRequest {
  RestaurantSetupRequestModel({
    required super.name,
    required super.logoUrl,
    required super.restaurantType,
    required super.cuisineTypes,
    required super.addressUrl,
    required super.openingTime,
    required super.closingTime,
    required super.openDays,
    required super.orderTypes,
    required super.totalTables,
    required super.isTaxed,
    required super.planType,
    required super.taxConfigurations,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'restaurantType': restaurantType,
      'cuisineTypes': cuisineTypes,
      'addressUrl': addressUrl,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'openDays': openDays,
      'orderTypes': orderTypes,
      'totalTables': totalTables,
      'isTaxed': isTaxed,
      'planType': planType,
      'taxConfigurations': TaxConfigurationModel.fromList(
        taxConfigurations,
      ).map((e) => e.toJson()).toList(),
    };
  }

  static RestaurantSetupRequestModel fromEntity(
    RestaurantSetupRequest request,
  ) {
    return RestaurantSetupRequestModel(
      name: request.name,
      logoUrl: request.logoUrl,
      restaurantType: request.restaurantType,
      cuisineTypes: List<String>.from(request.cuisineTypes),
      addressUrl: request.addressUrl,
      openingTime: request.openingTime,
      closingTime: request.closingTime,
      openDays: List<String>.from(request.openDays),
      orderTypes: List<String>.from(request.orderTypes),
      totalTables: request.totalTables,
      isTaxed: request.isTaxed,
      planType: request.planType,
      taxConfigurations: List<TaxConfiguration>.from(request.taxConfigurations),
    );
  }
}

class RestaurantSetupResponseModel extends RestaurantSetupResponse {
  RestaurantSetupResponseModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.restaurantType,
    required super.cuisineTypes,
    required super.addressUrl,
    required super.openingTime,
    required super.closingTime,
    required super.openDays,
    required super.orderTypes,
    required super.totalTables,
    required super.isTaxed,
    required super.planType,
    required super.taxConfigurations,
  });

  factory RestaurantSetupResponseModel.fromJson(Map<String, dynamic> json) {
    final taxConfigsJson = json['taxConfigurations'] as List<dynamic>? ?? [];
    final rawCuisine = json['cuisineTypes'];
    final cuisineTypes = rawCuisine is List
        ? rawCuisine.map((e) => e.toString()).toList()
        : <String>[];
    return RestaurantSetupResponseModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      restaurantType: json['restaurantType'] as String? ?? '',
      cuisineTypes: cuisineTypes,
      addressUrl: json['addressUrl'] as String? ?? '',
      openingTime: json['openingTime']?.toString() ?? '',
      closingTime: json['closingTime']?.toString() ?? '',
      openDays: (json['openDays'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      orderTypes: (json['orderTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      totalTables: (json['totalTables'] as num?)?.toInt() ?? 0,
      isTaxed: json['isTaxed'] as bool? ?? true,
      planType: json['planType'] as String? ?? '',
      taxConfigurations: taxConfigsJson
          .map((e) => TaxConfigurationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
