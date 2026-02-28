import 'dart:typed_data';

class OnboardingFlowData {
  final String? planType;
  final bool isAnnualBilling;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String? restaurantName;
  final String? restaurantType;
  final List<String> cuisineTypes;
  final bool? isMainBranch;
  final bool? hasMultipleBranches;
  final String? addressUrl;
  final String? logoUrl;
  final Uint8List? logoBytes;
  final String? logoFileName;
  final String? openingTime;
  final String? closingTime;
  final List<String> openDays;
  final List<String> orderTypes;
  final int? totalTables;
  final bool? isTaxed;
  final String? taxType;
  final num? taxPercentage;
  final num? serviceCharge;

  const OnboardingFlowData({
    this.planType,
    this.isAnnualBilling = false,
    this.username,
    this.email,
    this.phoneNumber,
    this.password,
    this.restaurantName,
    this.restaurantType,
    this.cuisineTypes = const [],
    this.isMainBranch,
    this.hasMultipleBranches,
    this.addressUrl,
    this.logoUrl,
    this.logoBytes,
    this.logoFileName,
    this.openingTime,
    this.closingTime,
    this.openDays = const [],
    this.orderTypes = const [],
    this.totalTables,
    this.isTaxed,
    this.taxType,
    this.taxPercentage,
    this.serviceCharge,
  });

  OnboardingFlowData copyWith({
    String? planType,
    bool? isAnnualBilling,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    String? restaurantName,
    String? restaurantType,
    List<String>? cuisineTypes,
    bool? isMainBranch,
    bool? hasMultipleBranches,
    String? addressUrl,
    String? logoUrl,
    Uint8List? logoBytes,
    String? logoFileName,
    String? openingTime,
    String? closingTime,
    List<String>? openDays,
    List<String>? orderTypes,
    int? totalTables,
    bool? isTaxed,
    String? taxType,
    num? taxPercentage,
    num? serviceCharge,
  }) {
    return OnboardingFlowData(
      planType: planType ?? this.planType,
      isAnnualBilling: isAnnualBilling ?? this.isAnnualBilling,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantType: restaurantType ?? this.restaurantType,
      cuisineTypes: cuisineTypes ?? List<String>.from(this.cuisineTypes),
      isMainBranch: isMainBranch ?? this.isMainBranch,
      hasMultipleBranches: hasMultipleBranches ?? this.hasMultipleBranches,
      addressUrl: addressUrl ?? this.addressUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      logoBytes: logoBytes ?? this.logoBytes,
      logoFileName: logoFileName ?? this.logoFileName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      openDays: openDays ?? List<String>.from(this.openDays),
      orderTypes: orderTypes ?? List<String>.from(this.orderTypes),
      totalTables: totalTables ?? this.totalTables,
      isTaxed: isTaxed ?? this.isTaxed,
      taxType: taxType ?? this.taxType,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      serviceCharge: serviceCharge ?? this.serviceCharge,
    );
  }
}
