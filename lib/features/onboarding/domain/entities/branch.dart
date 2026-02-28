import 'package:uuid/uuid.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final bool isHeadOffice;
  final double? latitude;
  final double? longitude;

  Branch({
    String? id,
    required this.name,
    required this.address,
    this.isHeadOffice = false,
    this.latitude,
    this.longitude,
  }) : id = id ?? const Uuid().v4();

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    bool? isHeadOffice,
    double? latitude,
    double? longitude,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isHeadOffice: isHeadOffice ?? this.isHeadOffice,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isHeadOffice': isHeadOffice,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      isHeadOffice: json['isHeadOffice'] as bool? ?? false,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}
