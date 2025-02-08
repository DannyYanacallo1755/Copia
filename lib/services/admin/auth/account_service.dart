import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ourshop_ecommerce/models/error/errors.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class AccountService {
  final Dio dio;

  AccountService({required this.dio});

  Future<Map<String, dynamic>> deleteAccount(String email, String password,
      context, AppLocalizations translations) async {
    try {
      late SharedPreferences preferences;
      preferences = await SharedPreferences.getInstance();
      final Map<String, dynamic> requestBody = {
        "username": email,
        "password": password
      };

      final response = await dio.post(
        '${dotenv.env['ADMIN_API_URL']}/users/delete/account',
        data: requestBody,
      );

      log('Response data: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      Fluttertoast.showToast(
        msg: translations.delete_account_success,
        gravity: ToastGravity.BOTTOM,
      );
      await preferences.clear().then(
        (_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false, // Esto eliminará todas las pantallas anteriores.
          );
        },
      );

      
      return data;
    } on DioException catch (e) {
      log('deleteAccount -> ${e.response?.data}');
      ErrorHandler(e);
      Fluttertoast.showToast(
        msg: "Error",
        gravity: ToastGravity.BOTTOM,
      );
      return {};
    }
  }
}
