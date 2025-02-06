import 'dart:developer';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class StripeService {
  final Dio dio;

  StripeService({required this.dio});

  Future<dynamic> createPaymentMethod(StripePayment data) async {
    try {
      final Response response = await dio.post(
        '/stripe/create-payment-intent',
        data: data.toMap(),
        // options: Options(
        //   contentType: Headers.formUrlEncodedContentType,
        //   headers: {
        //     'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
        //     'Content-Type': 'application/x-www-form-urlencoded',
        //   }
        // )
      );

      final StripeClient stripeClient = StripeClient.fromJson(response.data);
      return stripeClient;
    } on DioException catch (e) {
      log('Error creating payment method: $e');
      ErrorHandler(e);
    }
  }
}
