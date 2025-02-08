import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ourshop_ecommerce/provider/order-provider.dart';
import 'package:provider/provider.dart';
import '../../../models/address.dart';
import '../../../models/available_currency.dart';
import '../../../services/address-service.dart';
import '../pages.dart';
import 'shipping-address/address_page.dart';

enum CheckOutMode { order_detail, checkout }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ValueNotifier<bool> emitOrder = ValueNotifier<bool>(false);
  ValueNotifier<String?> _selectedAddressId = ValueNotifier<String?>(null);

  var addresId = '';
  var shippingAdressId = '';
  var shippingAdressObj;
  Currency? currency;
  bool _loading = true;

  List<Address> _savedAddresses = [];
  final AddressService _addressService = locator<AddressService>();
  final ValueNotifier<Address?> _selectedAddress =
      ValueNotifier<Address?>(null);

  @override
  void initState() {
    super.initState();
    _loadCurrency();

    context.read<CountryBloc>().add(const AddCountriesEvent());
    _loadAddresses();
  }

  void _loadCurrency() async {
    currency = await getCurrency();
    setState(() {
      _loading = false;
    });
  }

  Future<Currency?> getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency');
    if (currencies == null || currencies.isEmpty) {
      return null;
    }
    return Currency.fromJson(jsonDecode(currencies));
  }

  Future<void> _loadAddresses() async {
    try {
      final LoggedUser user = context.read<UsersBloc>().state.loggedUser;

      final String userId = user.userId;
      final String token = locator<Preferences>().preferences['refreshToken'];
      await _addressService.fetchAddresses(userId, token);
      if (_addressService.addresses.isNotEmpty) {
        setState(() {
          _savedAddresses = _addressService.addresses;
          _selectedAddress.value = _savedAddresses.first;
        });
      }
    } catch (e) {
      print('Failed to load addresses: $e');
    }
  }

  void saveInfo() async {
    late SharedPreferences preferences;
    preferences = await SharedPreferences.getInstance();
    preferences.setString('shippingAdressId', shippingAdressId);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;
    final LoggedUser loggedUser = context.watch<UsersBloc>().state.loggedUser;
    final dataProvider = Provider.of<OrderProvider>(context);

    return !_loading
        ? ValueListenableBuilder<bool>(
            valueListenable: emitOrder,
            builder: (BuildContext context, value, Widget? child) {
              if (value) {
                return OrderDetails(
                    shippingAddress: shippingAdressId, currency: currency!);
              }
              return child!;
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                automaticallyImplyLeading: true,
                title: Text(
                  translations.checkout,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              body: FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translations.client_information,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10.0),
                      FormBuilderTextField(
                        name: translations.name,
                        readOnly: true,
                        initialValue:
                            '${loggedUser.name} ${loggedUser.lastName}',
                        decoration: InputDecoration(
                            labelText: translations.name,
                            hintText: translations.name),
                      ),
                      const SizedBox(height: 10.0),
                      FormBuilderTextField(
                        name: translations.email,
                        readOnly: true,
                        initialValue: loggedUser.email,
                        decoration: InputDecoration(
                          labelText: translations.email,
                          hintText: translations.email,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      FormBuilderTextField(
                        name: translations.phone_number,
                        readOnly: true,
                        initialValue: loggedUser.userPhoneNumberCode +
                            loggedUser.userPhoneNumber,
                        decoration: InputDecoration(
                          labelText: translations.phone,
                          hintText: translations.phone,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        translations.shipping_information,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10.0),
                      ValueListenableBuilder<String?>(
                        valueListenable: _selectedAddressId,
                        builder: (context, selectedAddressId, _) {
                          return DropdownButtonFormField<String>(
                            value: selectedAddressId,
                            items: _savedAddresses.map((address) {
                              return DropdownMenuItem<String>(
                                value: address.id,
                                child: Text(address.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              _selectedAddressId.value = value;
                              final selectedAddress =
                                  _savedAddresses.firstWhere(
                                (address) => address.id == value,
                              );

                              if (selectedAddress != null) {
                                addresId = selectedAddress.countryId;
                                shippingAdressId = selectedAddress.id;
                                saveInfo();
                              } else {
                                print('Address not found for the given ID');
                              }
                            },
                            decoration: InputDecoration(
                              labelText: translations.address,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15.0),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Colors.white,
                        ),
                        label: Text(
                          translations.add_address,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddAddressScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20.0),
                      BlocBuilder<ProductsBloc, ProductsState>(
                        builder: (context, state) {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.cartProducts.length,
                            itemBuilder: (context, index) {
                              final FilteredProduct product =
                                  state.cartProducts[index];
                              return CartCard(
                                product: product,
                                currency: currency!,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                height: size.height * 0.1,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 25.0),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, -2),
                      blurRadius: 6.0)
                ]),
                child: BlocConsumer<ProductsBloc, ProductsState>(
                  listenWhen: (previous, current) =>
                      current.productsStates == ProductsStates.calculated &&
                      current.calculateShippingRangeresponse.success == true,
                  listener: (context, state) {
                    if (state.productsStates == ProductsStates.calculated &&
                        state.calculateShippingRangeresponse.success == true) {
                      emitOrder.value = true;
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.cartProducts.isEmpty ||
                              state.productsStates ==
                                      ProductsStates.calculating &&
                                  state.productsStates != ProductsStates.error
                          ? null
                          : () {
                              if (_formKey.currentState!.saveAndValidate()) {
                                final data = {"countryId": "", "products": []};
                                data['countryId'] = addresId;
                                data['products'] = context
                                    .read<ProductsBloc>()
                                    .state
                                    .cartProducts
                                    .map((e) => {
                                          'productId': e.id,
                                          'quantity': e.quantity,
                                          'price': e.unitPrice
                                        })
                                    .toList();
                                context.read<ProductsBloc>().add(
                                    CalculateShippingRateEvent(body: data));
                              }
                            },
                      child: state.productsStates == ProductsStates.calculating
                          ? const CircularProgressIndicator.adaptive()
                          : Text(
                              translations.submit_order,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                    );
                  },
                ),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator.adaptive());
  }
}

class OrderDetails extends StatelessWidget {
  final dynamic shippingAddress;
  final Currency currency;
  const OrderDetails(
      {super.key, required this.shippingAddress, required this.currency});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    Widget spacer = const SizedBox(
      height: 10.0,
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            translations.order_detail,
            style: theme.textTheme.titleLarge,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.55,
                width: size.width,
                child: ListView.builder(
                  itemCount:
                      context.watch<ProductsBloc>().state.cartProducts.length,
                  itemBuilder: (context, index) {
                    final FilteredProduct product =
                        context.watch<ProductsBloc>().state.cartProducts[index];
                    return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(0, 1),
                                    blurRadius: 5.0)
                              ]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: SizedBox(
                                  height: size.height * 0.15,
                                  width: size.width * 0.3,
                                  child: ProductImage(
                                    product: product,
                                    flagUrl: '',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        product.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                translations.quantity,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                product.quantity.toString(),
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                translations.price,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                currency.symbol != '\$'
                                                    ? '${currency.symbol} ${NumberFormat('#,###').format(product.unitPrice! * currency.dollarPrice)}'
                                                    : '\$${NumberFormat('#,###.00').format(product.unitPrice! * currency.dollarPrice)}',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                translations.sub_total(''),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                currency.symbol != '\$'
                                                    ? '${currency.symbol} ${NumberFormat('#,###').format((product.quantity ?? 1) * (product.unitPrice ?? 0) * currency.dollarPrice)}'
                                                    : '\$${NumberFormat('#,###.00').format((product.quantity ?? 1) * (product.unitPrice ?? 0) * currency.dollarPrice)}',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    width: size.width,
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              translations.order_cost,
                              style: theme.textTheme.titleLarge,
                            )),
                        spacer,
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${translations.sub_total(': ')}${currency.symbol != '\$' ? '${currency.symbol} ${NumberFormat('#,###').format(context.watch<ProductsBloc>().subtotal * currency.dollarPrice)}' : '\$${NumberFormat('#,###.00').format(context.watch<ProductsBloc>().subtotal * currency.dollarPrice)}'}',
                              style: theme.textTheme.titleMedium,
                            )),
                        spacer,
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${translations.order_shipping_cost(': \$')}${currency.symbol != '\$' ? '${currency.symbol} ${NumberFormat('#,###').format(context.read<ProductsBloc>().calculatedShipingRate * currency.dollarPrice)}' : '\$${NumberFormat('#,###.00').format(context.read<ProductsBloc>().calculatedShipingRate * currency.dollarPrice)}'}',
                              style: theme.textTheme.titleMedium,
                            )),
                        spacer,
                        const Divider(),
                        spacer,
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${translations.total_order(': ')}${currency.symbol != '\$' ? '${currency.symbol} ${NumberFormat('#,###').format((context.watch<ProductsBloc>().subtotal + context.read<ProductsBloc>().calculatedShipingRate) * currency.dollarPrice)}' : '\$${NumberFormat('#,###.00').format(context.watch<ProductsBloc>().subtotal + context.read<ProductsBloc>().calculatedShipingRate)}'}',
                              style: theme.textTheme.titleLarge,
                            )),
                        const Spacer(),
                        SizedBox(
                          width: size.width,
                          child: BlocConsumer<OrdersBloc, OrdersState>(
                            listenWhen: (previous, current) =>
                                current.ordersStatus ==
                                OrdersStatus.orderSubmitted,
                            listener:
                                (BuildContext context, OrdersState state) {
                              if (state.ordersStatus ==
                                  OrdersStatus.orderSubmitted) {
                                context
                                    .read<ProductsBloc>()
                                    .add(const ClearCart());
                                SuccessToast(
                                  title: translations.order_created,
                                  titleStyle: theme.textTheme.titleMedium
                                      ?.copyWith(color: Colors.white),
                                  backgroundColor: Colors.green,
                                  autoCloseDuration: const Duration(seconds: 2),
                                  onAutoCompleted: (_) {
                                    context.go('/home');
                                  },
                                ).showToast(context);
                              }
                            },
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.ordersStatus ==
                                            OrdersStatus.submittingOrder ||
                                        context
                                                .watch<UsersBloc>()
                                                .state
                                                .status ==
                                            UserStatus.paying
                                    ? null
                                    : () {
                                        final amount = (context
                                                .read<ProductsBloc>()
                                                .subtotal +
                                            context
                                                .read<ProductsBloc>()
                                                .calculatedShipingRate);

                                        context
                                            .read<UsersBloc>()
                                            .add(MakeStripePaymentEvent(
                                                stripePayment: StripePayment(
                                              amount: (context
                                                          .read<ProductsBloc>()
                                                          .subtotal *
                                                      100.00)
                                                  .toInt(),
                                              currency: currency.isoCode,
                                            )));
                                        saveInfo(amount, shippingAddress);
                                      },
                                child: state.ordersStatus ==
                                            OrdersStatus.submittingOrder ||
                                        context
                                                .watch<UsersBloc>()
                                                .state
                                                .status ==
                                            UserStatus.paying
                                    ? const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      )
                                    : Text(
                                        translations.submit_order,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                              );
                            },
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ));
  }

  void saveInfo(amount, shippingAddressId) async {
    late SharedPreferences preferences;
    preferences = await SharedPreferences.getInstance();
    preferences.setDouble('amount', amount);
    preferences.setString('shippingAdressId', shippingAddressId);
  }
}
