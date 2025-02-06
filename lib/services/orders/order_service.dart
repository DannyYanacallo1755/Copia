import 'dart:convert';
import 'dart:developer';

import 'package:ourshop_ecommerce/models/models.dart';

import '../../ui/pages/pages.dart';

class OrderService {
  final Dio dio;

  OrderService({required this.dio});

  Future<dynamic> getFilteredAdminOrders(
      Map<String, dynamic> filteredParameters) async {
    try {
      final response =
          await dio.post('/orders/filtered-page', data: filteredParameters);
      final filteredOrders = FilteredResponse<FilteredOrders>.fromJson(
          response.data, (json) => FilteredOrders.fromJson(json));
      return filteredOrders.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> getOrderbyId(String id) async {
    try {
      final response = await dio.get('/orders/$id');
      final data = OrderResponse.fromJson(response.data);
      return data.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> addNewOrder(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('/orders', data: body);
      final order = OrderResponse.fromJson(response.data);
      return order;
    } on DioException catch (e) {
      log('error adding new order: $e');
      ErrorHandler(e);
    }
  }

  Future<dynamic> updateOrder(Map<String, dynamic> body, id) async {
    try {
      final response = await dio.put('/orders/$id', data: body);

      if (response.statusCode == 200 && response.data != null) {
        final order = OrderResponse.fromJson(response.data);
        return order;
      } else {
        return {'success': false, 'message': 'Failed to update order'};
      }
    } on DioException catch (e) {
      log('error adding new order: ${e.message}');
      ErrorHandler(e);
    }
  }
}
