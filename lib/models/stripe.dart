import 'package:ourshop_ecommerce/models/models.dart';

class StripePayment extends Equatable{

  final int amount;
  final String currency;

  const StripePayment({
    required this.amount,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
  
  @override
  List<Object?> get props => [
    amount,
    currency,
  ];

}

class StripeClient extends Equatable{
  final String clientSecret;

  const StripeClient({required this.clientSecret});

  factory StripeClient.fromJson(Map<String, dynamic> json) =>  StripeClient(
    clientSecret: json['client_secret'],
  );
  
  @override
  List<Object?> get props => [
    clientSecret,
  ];


}