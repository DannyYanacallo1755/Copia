
import 'dart:developer';

import '../../../ui/pages/pages.dart';

class RoleServices {

  final Dio dio;
  RoleServices({required this.dio});

  Future<dynamic> getRoles() async {
    try {
      final Response response = await dio.get('/roles');
      final RoleResponse roles = RoleResponse.fromJson(response.data);
      return roles.data;
    } on DioException catch (e) {
      log('Roles->${e.response?.data}');
    }
  }
}