import 'package:ourshop_ecommerce/models/models.dart';

import '../ui/pages/pages.dart';

class DioInstance{

  final String _name;
  late Dio _dio;

  DioInstance(this._name,){
    final api = dotenv.env.keys.firstWhere((key) => key.split('_')[0].trim().toLowerCase() == _name.trim().toLowerCase());
    if (api.split('_')[0].trim().toLowerCase() == _name.trim().toLowerCase()) {
      _dio = Dio(
        BaseOptions(
          baseUrl: '${dotenv.env[api]}',
          headers: {
            'Referer': dotenv.env[api],
          },
          
        )
      );
      _dio.interceptors.addAll([RefreshTokenInterceptor()]);
    }
  }

  Dio get instance => _dio;
}

