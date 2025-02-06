import 'dart:developer';

import '../../../ui/pages/pages.dart';

class CategoryService {
  final Dio dio;

  CategoryService({required this.dio});

  Future<dynamic> getCategories() async {
    try {
      final response = await dio.get('/categories');
      final categoryResponse = CategoryResponse.fromJson(response.data);
      return categoryResponse.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getCategoryById(String categoryId) async {
    try {
      final response = await dio.get('/categories/$categoryId');
      final categoryResponse = CategoryResponse.fromJson(response.data);
      return categoryResponse.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getParentCategories() async {
    try {
      final response = await dio.get('/categories/parent');
      final subCategoryResponse = CategoryResponse.fromJson(response.data);
      return subCategoryResponse.data;
    } on DioException catch (e) {
      log('DioException: ${e.response?.data}');
      ErrorHandler(e);
    }
  }
}
