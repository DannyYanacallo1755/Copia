


import 'dart:developer';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class CompanyService {
  final Dio dio;
  CompanyService({required this.dio});

    Future<dynamic> getCompanies() async {
      try {
        final response = await dio.get('/companies');
        final companies = CompanyResponse.fromJson(response.data);
        return companies.data;
      } on DioException catch (e) {
        log('Get companies -> ${e.response?.data}');
        ErrorHandler(e);
      }
    }

    Future<dynamic> getCompanyById(String id) async {
      try {
        final response = await dio.get('/companies/$id');
        final company = CompanyResponse.fromJson(response.data);
        if (company.data is Company) {
          return company.data;
        }
      } on DioException catch (e) {
        log('getCompanyById -> ${e.response?.statusCode}');
        ErrorHandler(e);
      }
    }

    Future<dynamic> getCompanyByUserId(String id) async {
      try {
        final response = await dio.get('/companies/$id');
        final Company company = Company.fromJson(response.data);
        return company;
      } on DioException catch (e) {
        // log('${e.response?.data}');
        ErrorHandler(e);
      }
    }

    Future<dynamic> uploadCompnayLogo(File logo) async {
      try {
        final response = await dio.post('/companies/photo', data: FormData.fromMap({
          'file': await MultipartFile.fromFile(logo.path, filename: logo.path.split('/').last ),
        }));
        if (response.data is Map<String,dynamic> && response.data['success'] == true) {
          SuccessToast(
            title: response.data['message'],
            style: ToastificationStyle.flatColored,
            foregroundColor: Colors.white,
            backgroundColor: Colors.green.shade500,
          ).showToast(AppRoutes.globalContext!);
        }
        return response.data;
      } on DioException catch (e) {
        log('${e.response?.data}');
        ErrorHandler(e);
      }
    }

    Future<dynamic> getBanksByCountry (Map<String,dynamic> filteredParams) async {
      try {
        final response = await dio.post('/banks/filtered-page', data: filteredParams);
        final banks = FilteredResponse<FilteredBanks>.fromJson(response.data, (json) => FilteredBanks.fromJson(json));
        return banks.data;
      } on DioException catch (e) {
        log('getBanksByCompany -> ${e.response?.data}');
        ErrorHandler(e);
      }
    }


    Future<dynamic> updateCompanyInformation(String companyId, Map<String, dynamic> body) async {
      try {
        final response = await dio.put('/companies/$companyId', data: body);
        final resp = CompanyResponse.fromJson(response.data);
        if (resp.success && resp.data is Company) {
          return resp.data;
        }
        return response.data;
      } on DioException catch (e) {
        log('${e.response?.data}');
        ErrorHandler(e);
      }
    }
  }