import 'package:ourshop_ecommerce/models/available_currency.dart';

import '../../../ui/pages/pages.dart';

class CurrencyService {
  final Dio dio;

  CurrencyService({required this.dio});

  Future<dynamic> getCurrency() async {
    try {
      final response = await dio.get(
        '/currency-types/with-prices?language=es',
      );
      final currency = CurrencyResponse.fromJson(response.data);
      return currency.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }
}
