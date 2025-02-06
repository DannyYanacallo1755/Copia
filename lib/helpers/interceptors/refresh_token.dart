import 'dart:async';
import 'dart:developer';

import '../../ui/pages/pages.dart';

class RefreshTokenInterceptor extends Interceptor {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = locator<Preferences>().preferences['token'];
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // log('Error interceptor: ${err.response?.data}');
    if (err.response?.statusCode == 401 && err.response?.data['message'] == 'Unauthorized') {
      log('Unauthorized - Intentando refrescar el token');
      ErrorHandler(err);
      // Evitar bucle infinito, chequeando si ya intentó refrescar el token una vez
      final options = err.requestOptions;

      if (options.headers['retry'] == true) {
        // Si ya se intentó reintentar esta solicitud, evitar bucle infinito
        log('Token refrescado previamente - No reintentando');
        return handler.next(err);
      }

      options.headers['retry'] = true;  // Marcar esta solicitud para evitar múltiples reintentos

      final refreshToken = locator<Preferences>().preferences['refreshToken'];
      
      if (refreshToken.isNotEmpty) {
        try {
          // Refrescar el token
          // await locator<AuthService>().refreshToken(refreshToken);
          // final newToken = locator<Preferences>().preferences['token'];

          // Agregar el nuevo token a la solicitud original
          // options.headers['Authorization'] = 'Bearer $newToken';

          // Reintentar la solicitud original
          // final response = await locator<DioInstance>().instance.fetch(options);
          // return handler.resolve(response);
        } catch (e) {
          log('Error al refrescar el token: $e');
          return handler.next(err);  // Si falla el refresh, devuelve el error
        }
      } else {
        return handler.next(err);  // Si no hay refresh token, pasa el error
      }
    } else {
      return handler.next(err);  // Si no es un error 401, continúa con el manejo del error
    }
  }
}
