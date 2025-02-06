import 'dart:developer';

import '../../ui/pages/pages.dart';

class CommunicationService {
  final Dio dio;

  CommunicationService({required this.dio});

  Future<dynamic> getSubmissions(Map<String,dynamic> filteredParams) async {
    try {
      final response = await dio.post('/requests/filtered-page', data: filteredParams);
      final  submissions = FilteredResponse<FilteredRequests>.fromJson(response.data, (json) => FilteredRequests.fromJson(json));
      return submissions.data;
    }on DioException catch (e) {
      log('getSubmissions: ${e.response?.data}');
      ErrorHandler(e);
    }
  }
}