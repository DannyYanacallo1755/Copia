import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ourshop_ecommerce/services/address-service.dart';
import 'package:ourshop_ecommerce/services/products/product/currency_service.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

import 'communication/websocket_service.dart';

GetIt locator = GetIt.instance;

Future<void> initializeServiceLocator() async {
  locator.registerLazySingleton<AppLocalizations>(
      () => AppLocalizations.of(AppRoutes.globalContext!)!);
  locator.registerLazySingleton(() => Preferences());
  locator.registerLazySingleton(() => ImagePicker());
  Stripe.publishableKey = dotenv.env['STRIPE_SECRET_KEY']!;
  // get preferences
  await locator<Preferences>().getpreferences();

  locator.registerSingleton(GeneralBloc());
  final int parsetValue = locator<Preferences>().preferences['language'] != null
      ? int.parse(locator<Preferences>().preferences['language'])
      : 1;
  locator
      .registerSingleton(SettingsBloc())
      .add(ChangeSelectedLanguage(selectedLanguage: parsetValue));

  //admin
  await admin(DioInstance('admin').instance);

  //product
  await product(DioInstance('product').instance);

  //order
  await order(DioInstance('order').instance);

  //
  await communication(DioInstance('communication').instance);

  // Registro del servicio WebSocket
  locator.registerLazySingleton<WebSocketService>(() => WebSocketService());
}

Future<void> admin(Dio instance) async {
  final AuthService authService =
      locator.registerSingleton(AuthService(dio: instance));

  final RoleServices roleServices =
      locator.registerSingleton(RoleServices(dio: instance));
  locator.registerSingleton(RolesBloc(roleServices));

  final CompanyService companyService =
      locator.registerSingleton(CompanyService(dio: instance));
  final SocialMediaService socialMediaService =
      locator.registerSingleton(SocialMediaService(dio: instance));

  locator.registerSingleton(CompanyBloc(companyService, socialMediaService));

  final CountryService countryService =
      locator.registerSingleton(CountryService(dio: instance));
  locator.registerSingleton(CountryBloc(countryService));
  locator.registerLazySingleton(() => StripeService(dio: instance));
  locator.registerSingleton(UsersBloc(authService, locator<SettingsBloc>(),
      locator<GeneralBloc>(), locator<StripeService>()));
  locator.registerLazySingleton<AddressService>(() => AddressService());

  // get roles...
  // await rolesBloc.getRoles();

  // get companies...

  // await companyBloc.getCompanies();

  // get countries...
  // await countryBloc.fetchCountries();
}

Future<void> product(Dio instance) async {
  final ProductService productService =
      locator.registerSingleton(ProductService(dio: instance));
  final CategoryService categoryService =
      locator.registerSingleton(CategoryService(dio: instance));
  final CurrencyService currencyService =
      locator.registerSingleton(CurrencyService(dio: instance));
  locator.registerSingleton(
      ProductsBloc(productService, categoryService, currencyService));
}

Future<void> order(Dio instance) async {
  final OrderService orderService =
      locator.registerSingleton(OrderService(dio: instance));
  locator.registerSingleton(OrdersBloc(orderService));
}

Future<void> communication(Dio instance) async {
  final communicationService =
      locator.registerSingleton(CommunicationService(dio: instance));
  locator.registerSingleton(CommunicationBloc(communicationService));
}
