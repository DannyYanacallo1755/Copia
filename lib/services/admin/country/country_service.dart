

import 'dart:developer';

import '../../../ui/pages/pages.dart';

class CountryService{

  final Dio dio;

  CountryService({required this.dio});

  Future<dynamic> getCountries() async {
    try {
      final response = await dio.get('/countries');
      final countries = CountryResponse.fromJson(response.data);
      return countries.data;
    } on DioException catch (e) {
      log('CountryService->${e.response?.data}');
      ErrorHandler(e);
    }
    
    
  }
}