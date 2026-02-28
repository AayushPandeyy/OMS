import 'package:oms/features/onboarding/domain/entities/tax_configuration.dart';

class TaxConfigurationModel extends TaxConfiguration {
  const TaxConfigurationModel({
    required super.taxType,
    required super.taxPercentage,
    super.serviceCharge,
  });

  factory TaxConfigurationModel.fromJson(Map<String, dynamic> json) {
    return TaxConfigurationModel(
      taxType: json['taxType'] as String? ?? '',
      taxPercentage: (json['taxPercentage'] as num?) ?? 0,
      serviceCharge: json['serviceCharge'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taxType': taxType,
      'taxPercentage': taxPercentage,
      if (serviceCharge != null) 'serviceCharge': serviceCharge,
    };
  }

  static List<TaxConfigurationModel> fromList(List<TaxConfiguration> items) {
    return items
        .map(
          (item) => TaxConfigurationModel(
            taxType: item.taxType,
            taxPercentage: item.taxPercentage,
            serviceCharge: item.serviceCharge,
          ),
        )
        .toList();
  }
}
