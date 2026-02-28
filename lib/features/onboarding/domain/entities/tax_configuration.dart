class TaxConfiguration {
  final String taxType;
  final num taxPercentage;
  final num? serviceCharge;

  const TaxConfiguration({
    required this.taxType,
    required this.taxPercentage,
    this.serviceCharge,
  });
}
