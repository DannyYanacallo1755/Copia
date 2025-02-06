import 'package:equatable/equatable.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class CountryResponse {
  bool success;
  String message;
  List<Country> data;

  CountryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) =>
      CountryResponse(
        success: json["success"],
        message: json["message"],
        data: List<Country>.from(json["data"].map((x) => Country.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Country extends Equatable {
  final String id;
  final String name;
  final String iso;
  final String iso3;
  final int numCode;
  final int phoneCode;
  final String flagUrl;

  const Country({
    required this.id,
    required this.name,
    required this.iso,
    required this.iso3,
    required this.numCode,
    required this.phoneCode,
    required this.flagUrl,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json["id"],
        name: json["name"],
        iso: json["iso"],
        iso3: json["iso3"],
        numCode: json["numCode"],
        phoneCode: json["phoneCode"],
        flagUrl: json["flagUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "iso": iso,
        "iso3": iso3,
        "numCode": numCode,
        "phoneCode": phoneCode,
        "flagUrl": flagUrl,
      };

  /// Fábrica para crear un objeto Country vacío
  factory Country.empty() {
    return const Country(
      id: '',
      name: '',
      iso: '',
      iso3: '',
      numCode: 0,
      phoneCode: 0,
      flagUrl: '',
    );
  }

  @override
  List<Object?> get props => [id, name, iso, iso3, numCode, phoneCode, flagUrl];
}
