import 'package:equatable/equatable.dart';

class CurrencyResponse extends Equatable {
  final bool success;
  final String message;
  final List<Currency> data;

  const CurrencyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) =>
      CurrencyResponse(
        success: json["success"],
        message: json["message"],
        data:
            List<Currency>.from(json["data"].map((x) => Currency.fromJson(x))),
      );

  @override
  List<Object?> get props => [
        success,
        message,
        data,
      ];
}

class Currency extends Equatable {
  final String symbol;
  final String name;
  final int rounding;
  final String symbolNative;
  final String isoCode;
  final int decimalDigits;
  final String namePlural;
  final double dollarPrice;

  const Currency({
    required this.symbol,
    required this.name,
    required this.rounding,
    required this.symbolNative,
    required this.isoCode,
    required this.decimalDigits,
    required this.namePlural,
    required this.dollarPrice,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      symbol: json['symbol'],
      name: json['name'],
      rounding: json['rounding'],
      symbolNative: json['symbol_native'],
      isoCode: json['iso_code'],
      decimalDigits: json['decimal_digits'],
      namePlural: json['name_plural'],
      dollarPrice: json['latest_price']['dollarPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'rounding': rounding,
      'symbol_native': symbolNative,
      'iso_code': isoCode,
      'decimal_digits': decimalDigits,
      'name_plural': namePlural,
      'latest_price': {
        'dollarPrice': dollarPrice,
      },
    };
  }

  /// 🔹 Método para devolver una moneda por defecto (USD)
  static Currency defaultCurrency() {
    return const Currency(
      symbol: "\$",
      name: "US Dollar",
      rounding: 0,
      symbolNative: "\$",
      isoCode: "USD",
      decimalDigits: 2,
      namePlural: "US dollars",
      dollarPrice: 1.0, // 💲 Precio en dólares
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        name,
        rounding,
        symbolNative,
        isoCode,
        decimalDigits,
        namePlural,
        dollarPrice,
      ];
}
