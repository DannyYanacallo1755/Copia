part of 'users_bloc.dart';

enum UserStatus {
  login,
  logged,
  registering,
  registered,
  loading,
  loaded,
  success,
  error,
  initial,
  paying,
  paid,
  getting_client_sercret,
  got_client_secret,
}

class UsersState extends Equatable {

  final LoggedUser loggedUser;
  final List<PaymentMethodCustom> cards;
  final PaymentMethodCustom selectedCard;
  final ShippingAddress selectedShippingAddress;
  final List<ShippingAddress> shippingAddresses;
  final UserStatus status;
  final StripeClient stripeClient;

  const UsersState({
      this.loggedUser = const LoggedUser(
        userCountryName: "",
        sub: "",
        companyId: "",
        roles: "",
        companyCountryName: "",
        lastName: "",
        language: "",
        companyMainCategoryId: "",
        companyCurrentBusinessCategoryId: "",
        userPhoneNumber: "",
        companyCountryId: "",
        userId: "",
        userCountryId: "",
        companyName: "",
        name: "",
        userPhoneNumberCode: "",
        exp: 0,
        iat: 0,
        email: "",
      ),
      this.cards = const [],
      this.selectedCard = const PaymentMethodCustom(
        id: "",
        cardNumber: "",
        type: CardType.UNKNOWN,
        expirationDate: "",
        cvv: "",
      ),
      this.selectedShippingAddress = const ShippingAddress(
        id: '1',
        country: "United States",
        fullName: "John Doe",
        phoneNumber: "+1 1234567890",
        address: "123 Main St",
        addtionalInstructions: "Apartment 4B",
        postalCode: 12345,
        state: "California",
        municipality: "Los Angeles", 
      ),
      this.shippingAddresses = const [],
      this.status = UserStatus.initial,
      this.stripeClient = const StripeClient(clientSecret: "",),
    });

  UsersState copyWith({
    LoggedUser? loggedUser,
    List<PaymentMethodCustom>? cards,
    PaymentMethodCustom? selectedCard,
    ShippingAddress? selectedShippingAddress,
    UserStatus? status,
    StripeClient? stripeClient,
  }) {
    return UsersState(
      loggedUser: loggedUser ?? this.loggedUser,
      cards: cards ?? this.cards,
      selectedCard: selectedCard ?? this.selectedCard,
      selectedShippingAddress: selectedShippingAddress ?? this.selectedShippingAddress,
      status: status ?? this.status,
      stripeClient: stripeClient ?? this.stripeClient,
    );
  }
  
  @override
  List<Object> get props => [
    loggedUser,
    cards,
    selectedCard,
    selectedShippingAddress,
    status,
    stripeClient,
  ];
}
