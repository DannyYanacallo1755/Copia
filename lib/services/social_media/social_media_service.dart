

import 'dart:developer';
import '../../ui/pages/pages.dart';

class SocialMediaService {

  final Dio dio;
  SocialMediaService({required this.dio});

  Future<dynamic> getSocialMedias() async {
    try {
      final response = await dio.get('/social-media');
      final socialMedias = SocialMediaResponse.fromJson(response.data);
      return socialMedias.data;
    } on DioException catch (e) {
      log('Get social medias -> ${e.response?.data}');
      ErrorHandler(e);
    }
  }
  
}