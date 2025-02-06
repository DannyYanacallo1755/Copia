class Address {
  final String id;
  final String name;
   String countryId;
   String stateId;
   String cityId;
  final String postalCode;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String addressLine3;
  final String userId;

  Address({
    required this.id,
    required this.name,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.postalCode,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2 = '',
    this.addressLine3 = '',
    required this.userId,
  });
   factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'],
      countryId: json['countryId'],
      stateId: json['stateId'],
      cityId: json['cityId'],
      postalCode: json['postalCode'],
      phoneNumber: json['phoneNumber'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      userId: json['userId'],
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryId': countryId,
      'stateId': stateId,
      'cityId': cityId,
      'postalCode': postalCode,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'userId': userId,
    };
  }

  Address copyWith(
      {String? id,
      String? name,
      String? country,
      String? state,
      String? city,
      String? postalCode,
      String? phoneNumber,
      String? addressLine1,
      String? addressLine2,
      String? addressLine3,
      String? userId}) {
    return Address(
        id: id ?? this.id,
        name: name ?? this.name,
        countryId: countryId ?? this.countryId,
        stateId: stateId ?? this.stateId,
        cityId: cityId ?? this.cityId,
        postalCode: postalCode ?? this.postalCode,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        addressLine1: addressLine1 ?? this.addressLine1,
        addressLine2: addressLine2 ?? this.addressLine2,
        addressLine3: addressLine3 ?? this.addressLine3,
        userId: userId ?? this.userId);
  }
}
