import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../ui/pages/pages.dart';
part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final AuthService _userServices;
  final SettingsBloc _settingsBloc;
  final GeneralBloc generalBloc;
  final StripeService _stripeService;
  UsersBloc(AuthService userServices, SettingsBloc settingsBloc,
      this.generalBloc, StripeService stripeService)
      : _userServices = userServices,
        _settingsBloc = settingsBloc,
        _stripeService = stripeService,
        super(const UsersState()) {
/*añiadido para el inicio de sesion con apple */
      on<LoginApple>((event, emit) async {
        try {
          emit(state.copyWith(status: UserStatus.loading));
          final response = await _userServices.loginApple();
          if (response is LoggedUser) {
            emit(state.copyWith(
            loggedUser: response,
            status: UserStatus.logged,
            ));
          } else {
            emit(state.copyWith(status: UserStatus.error));
          }
        } catch (e) {
            emit(state.copyWith(status: UserStatus.error));
        }
        });

    on<Login>((event, emit) async {
      try {
        emit(state.copyWith(status: UserStatus.loading));
        final Auth auth = Auth(
          username: event.data['username'],
          password: event.data['password'],
        );
        final response = await _userServices.login(auth);
        if (response is LoggedUser) {
          emit(state.copyWith(
            loggedUser: response,
            status: UserStatus.logged,
          ));
        }
        emit(state.copyWith(status: UserStatus.initial));
      } catch (e) {
        emit(state.copyWith(status: UserStatus.error));
      }
    });
    on<LoginGoogle>((event, emit) async {
      try {
        emit(state.copyWith(status: UserStatus.loading));
        final response = await _userServices.loginGoogle();
        if (response is LoggedUser) {
          emit(state.copyWith(
            loggedUser: response,
            status: UserStatus.logged,
          ));
          emit(state.copyWith(status: UserStatus.initial));
        } else {
          emit(state.copyWith(status: UserStatus.error));
        }
      } catch (e) {
        emit(state.copyWith(status: UserStatus.error));
      }
    });

    on<RegisterGoogle>((event, emit) async {
      try {
        emit(state.copyWith(status: UserStatus.loading));
        final response = await _userServices.registerGoogle();

        if (response is LoggedUser) {
          emit(state.copyWith(
            loggedUser: response,
            status: UserStatus.logged,
          ));
        } else {
          emit(state.copyWith(status: UserStatus.error));
        }
        emit(state.copyWith(status: UserStatus.initial));
      } catch (e) {
        emit(state.copyWith(status: UserStatus.error));
      }
    });

    on<RegisterNewUser>((event, emit) async {
      try {
        emit(state.copyWith(status: UserStatus.registering));
        final NewUser newUser = NewUser(
          username: event.data['email'],
          email: event.data['email'],
          password: event.data['password'],
          name: event.data['name'],
          lastName: event.data['lastName'],
          phoneNumberCode: event.data['phoneNumberCode'],
          phoneNumber: event.data['phoneNumber'],
          countryId: event.data['countryId'],
          companyName: event.data['companyName'],
          rolesIds: event.data['rolesIds'],
          language: _settingsBloc.state.currentLanguage.value,
        );
        final dynamic user = await _userServices.register(newUser);
        if (user is User) {
          emit(state.copyWith(status: UserStatus.registered));
        }
        emit(state.copyWith(status: UserStatus.initial));
      } catch (e) {
        emit(state.copyWith(status: UserStatus.error));
      }
    });
    on<AddPaymentMethodsEvent>(
        (event, emit) => emit(state.copyWith(cards: event.cards)));
    on<AddPaymentMethodEvent>((event, emit) =>
        emit(state.copyWith(cards: List.from(state.cards)..add(event.card))));
    on<RemovePaymentMethodEvent>((event, emit) => emit(
        state.copyWith(cards: List.from(state.cards)..remove(event.card))));
    on<AddSelectedCardEvent>(
        (event, emit) => emit(state.copyWith(selectedCard: event.card)));

    on<AddSelectedShippingAddressEvent>((event, emit) =>
        emit(state.copyWith(selectedShippingAddress: event.shippingAddress)));

    on<MakeStripePaymentEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: UserStatus.paying));
        final response =
            await _stripeService.createPaymentMethod(event.stripePayment);

        if (response is StripeClient) {
          await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: response.clientSecret,
            merchantDisplayName: 'OurShop',
          ));
          await Stripe.instance.presentPaymentSheet();
          final PaymentIntent paymentIntent = await Stripe.instance
              .retrievePaymentIntent(response.clientSecret);
          late SharedPreferences preferences;
          preferences = await SharedPreferences.getInstance();

          var shippingAddressId = preferences.getString('shippingAdressId');
          var amount = preferences.getDouble('amount') ?? 0.0;
          var shippingRangeCalculation =
              preferences.getString('shippingRangeCalculation');
          var cartProducts = locator<ProductsBloc>().state.cartProducts;
          final Map<String, dynamic> data = {
            "customerId": state.loggedUser.userId,
            "discount": 0,
            "orderItems": cartProducts.map((e) {
              return {
                "productId": e.id,
                "qty": e.quantity,
                "price": e.unitPrice,
              };
            }).toList(),
            "shippingRangeCalculation": shippingRangeCalculation != null
                ? jsonDecode(shippingRangeCalculation)
                : [],
            "amount": amount,
            "currencyType": "USD",
            "payment": paymentIntent.toJson(),
            "shippingAddressId": shippingAddressId,
          };

          locator<OrdersBloc>().add(NewOrderEvent(data: data));

          emit(state.copyWith(status: UserStatus.paid));
          preferences.remove('amount');
          preferences.remove('shippingAdressId');
          preferences.remove('shippingRangeCalculation');
        }
      } on StripeException catch (e) {
        log('StripeException: ${e.error.message}');
        emit(state.copyWith(status: UserStatus.error));
      } catch (e) {
        log('e: $e');
        emit(state.copyWith(status: UserStatus.initial));
      }
    });
  }
}
