import 'dart:developer';
import '../../../ui/pages/pages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService {
  final Dio dio;

  ProductService({required this.dio});

  Future<dynamic> getProducts() async {
    try {
      final response = await dio.get(
        '/products',
      );
      final products = ProductResponse.fromJson(response.data);
      return products.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getCategories() async {
    try {
      final response = await dio.get('/categories');
      final CategoryResponse categoryResponse =
          CategoryResponse.fromJson(response.data);
      return categoryResponse.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getProductsByCategory(String categoryId) async {
    log('categoryId: $categoryId');
    try {
      final response = await dio.get('/products/by-category/$categoryId');
      final products = FilteredResponse<FilteredProduct>.fromJson(
          response.data, (json) => FilteredProduct.fromJson(json));
      return products.data;
    } on DioException catch (e) {
      log(e.response?.data);
      ErrorHandler(e);
    }
  }

  Future<dynamic> getReviewByProduct(String productId) async {
    try {
      final response = await dio.get('/product-reviews/product/$productId');
      final reviews = ReviewsResponse.fromJson(response.data);
      return reviews.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> filteredAdminProducts(
      Map<String, dynamic> filteredParamenters) async {
    try {
      log('url: ${dio.options.baseUrl}');
      final response =
          await dio.post('/products/filtered-page', data: filteredParamenters);
      final filteredProducts = FilteredResponse<FilteredProduct>.fromJson(
          response.data, (json) => FilteredProduct.fromJson(json));
      return filteredProducts.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> deleteAdminProductById(String productId) async {
    try {
      await dio.delete('/products/$productId');
      SuccessToast(
        title: locator<AppLocalizations>().product_deleted,
        style: ToastificationStyle.flatColored,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green.shade500,
      ).showToast(AppRoutes.globalContext!);
      return true;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> filteredProducts(Map<String, dynamic> filteredParamenters,
      [String? categoryId = '']) async {
    try {
      log('categroryId: $categoryId');
      final originalBaseUrl = dio.options.baseUrl;

      final response = await dio.post(
          categoryId != null && categoryId.isNotEmpty && categoryId != 'all'
              ? '/products/filtered-page/$categoryId'
              : '/products/filtered-page',
          data: filteredParamenters);

      final filteredProducts = FilteredResponse<FilteredProduct>.fromJson(
          response.data, (json) => FilteredProduct.fromJson(json));

      dio.options.baseUrl = 'https://admin-api.os-develop.site/api';
      final countriesResponse = await dio.get('/countries');
      final List<dynamic> countriesList = countriesResponse.data['data'];
      final countries =
          countriesList.map((country) => Country.fromJson(country)).toList();
      dio.options.baseUrl = originalBaseUrl;
      for (var i = 0; i < filteredProducts.data.content.length; i++) {
        final product = filteredProducts.data.content[i];

        final matchingCountry = countries.firstWhere(
            (country) => country.id == product.companyCountryId, orElse: () {
          log('País no encontrado para companyCountryId: ${product.companyCountryId}');
          return Country.empty();
        });
        filteredProducts.data.content[i] =
            product.copyWith(flagUrl: matchingCountry.flagUrl);
      }
      return filteredProducts.data;
    } on DioException catch (e) {
      log('error filteredProducts: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> filteredCountriesGroup(
      Map<String, dynamic> filteredParams) async {
    try {
      final response =
          await dio.post('/country-groups/filtered-page', data: filteredParams);
      final countriesGroup = FilteredResponse<FilteredGroupCountries>.fromJson(
          response.data, (json) => FilteredGroupCountries.fromJson(json));
      return countriesGroup.data;
    } on DioException catch (e) {
      log('filteredCountriesGroup: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getProductGroups() async {
    try {
      final response = await dio.get('/product-groups');
      final productGroups = ProductGroupsResponse.fromJson(response.data);
      return productGroups.data;
    } on DioException catch (e) {
      log('error productGroups: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getProductsType() async {
    try {
      final response = await dio.get('/product-types');
      final productTypes = ProductTypeResponse.fromJson(response.data);
      return productTypes.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getUnitMeasurement() async {
    try {
      final response = await dio.get('/unit-measurements');
      final unitMeasurements = UnitMeasurementResponse.fromJson(response.data);
      return unitMeasurements.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> addNewProduct(FormData formData) async {
    try {
      final response = await dio.post('/products',
          data: formData, options: Options(contentType: 'multipart/form-data'));
      if (response.data['success'] == true) {
        SuccessToast(
          title: locator<AppLocalizations>().product_added,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade500,
        ).showToast(AppRoutes.globalContext!);
      }
    } on DioException catch (e) {
      log('error addNewProduct: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<String> updateProduct(
      FormData formData, String token, String id) async {
    try {
      // URL de la API
      final uri = Uri.parse('${dotenv.env['ADMIN_API_URL']}/products/$id');

      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Content-Type'] = 'multipart/form-data';

      formData.fields.forEach((field) {
        request.fields[field.key] = field.value;
      });
      for (var file in formData.files) {
        final fileName = file.value.filename ?? 'file';

        request.files.add(http.MultipartFile(
          file.key,
          file.value.finalize(),
          file.value.length,
          filename: fileName,
        ));
      }

      // Enviar la solicitud
      var response = await http.Response.fromStream(await request.send());

      // Leer y procesar la respuesta
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print(response.statusCode);
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error updating product: $e';
    }
  }

  Future<dynamic> updateCountryGroupById(
      String countryGroupId, Map<String, dynamic> body) async {
    try {
      final response =
          await dio.put('/country-groups/$countryGroupId', data: body);
      log('updateCountryGroupById: ${response.data}');
    } on DioException catch (e) {
      log('error updateCountryGroupById: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getCountryGroupsByCompany(String companyId) async {
    try {
      final response = await dio.get('/country-groups/company');
      final countryGroups = CountryGroupResponse.fromJson(response.data);
      return countryGroups.data;
    } on DioException catch (e) {
      log('error getCountryGroupsByCompany: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> addNewCountryGroup(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('/country-groups', data: body);
      if (response.data['success'] == true) {
        SuccessToast(
          title: locator<AppLocalizations>().country_group_added,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade500,
        ).showToast(AppRoutes.globalContext!);

        return true;
      }
    } on DioException catch (e) {
      log('error addNewCountryGroup: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getShippingRates(Map<String, dynamic> filteredParams) async {
    try {
      final response =
          await dio.post('/shipping-rates/filtered-page', data: filteredParams);
      final shippingRates = FilteredResponse<FilteredShippingRate>.fromJson(
          response.data, (json) => FilteredShippingRate.fromJson(json));
      return shippingRates.data;
    } on DioException catch (e) {
      log('error getShippingRates: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> addNewShippingRate(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('/shipping-rates', data: body);
      if (response.data['success'] == true) {
        SuccessToast(
          title: locator<AppLocalizations>().shipping_rate_added,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade500,
        ).showToast(AppRoutes.globalContext!);
      }
    } on DioException catch (e) {
      log('error addNewShippingRate: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getFilteredOfferTypes(
      Map<String, dynamic> filteredParams) async {
    try {
      final response =
          await dio.post('/offer-types/filtered-page', data: filteredParams);
      final offerTypes = FilteredResponse<FilteredOfferTypes>.fromJson(
          response.data, (json) => FilteredOfferTypes.fromJson(json));
      return offerTypes.data;
    } on DioException catch (e) {
      log('error getFilteredOfferTypes: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getSearchProductShippingRates(String query) async {
    try {
      final response = await dio.get('/products/search/$query');
      final searchProductShippingRates =
          ProductResponse.fromJson(response.data);
      return searchProductShippingRates.data;
    } on DioException catch (e) {
      log('DioException: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> calculateshippingRate(Map<String, dynamic> data) async {
    try {
      final String token = locator<Preferences>().preferences['refreshToken'];

      final response = await http.post(
          Uri.parse('${dotenv.env['ORDER_API_URL']}/shipping-rates/calculate'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(data));
      final decodedResponse =
          json.decode(response.body) as Map<String, dynamic>;

      final calculate =
          CalculateShippingRangeresponse.fromJson(decodedResponse);
      if (calculate.success == false) {
        ErrorToast(
          title: calculate.message!,
          style: ToastificationStyle.flatColored,
          backgroundColor: Colors.red,
        ).showToast(AppRoutes.globalContext!);
      }
      return calculate;
    } on DioException catch (e) {
      ErrorToast(
        title: e.response?.data,
        style: ToastificationStyle.flatColored,
        backgroundColor: Colors.red,
      ).showToast(AppRoutes.globalContext!);
      log('error calculateshipping: ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> getProdutsOffers(Map<String, dynamic> filteredParams) async {
    try {
      final originalBaseUrl = dio.options.baseUrl;
      final response =
          await dio.post('/offers/filtered-page', data: filteredParams);
      final productsOffers = FilteredResponse<FilteredOfferProduct>.fromJson(
          response.data, (json) => FilteredOfferProduct.fromMap(json));

      dio.options.baseUrl = 'https://admin-api.os-develop.site/api';
      final countriesResponse = await dio.get('/countries');
      final List<dynamic> countriesList = countriesResponse.data['data'];
      final countries =
          countriesList.map((country) => Country.fromJson(country)).toList();
      dio.options.baseUrl = originalBaseUrl;
      for (var i = 0; i < productsOffers.data.content.length; i++) {
        final product = productsOffers.data.content[i];

        final matchingCountry = countries.firstWhere(
            (country) => country.id == product.product?.companyCountryId,
            orElse: () {
          log('País no encontrado para companyCountryId: ${product.product?.companyCountryId}');
          return Country.empty();
        });
        productsOffers.data.content[i] =
            product.copyWith(flagUrl: matchingCountry.flagUrl);
      }
      return productsOffers.data;
    } on DioException catch (e) {
      log('error getProdutsOffers: ${e.response?.data}');
      ErrorHandler(e);
    }
  }
}



//TODO pasos

// - caluclar el costo de envio