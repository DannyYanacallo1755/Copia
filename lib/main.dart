import 'package:firebase_core/firebase_core.dart';
import 'package:ourshop_ecommerce/firebase_options.dart';
import 'package:ourshop_ecommerce/provider/order-provider.dart';
import 'ui/pages/pages.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WakelockPlus.enable();
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  await dotenv.load(fileName: isProduction ? ".env.prod" : ".env.dev");
  Bloc.observer = Observable();
  await initializeServiceLocator();
  //final webSocketService = locator<WebSocketService>();
  //webSocketService.connect();

  /* webSocketService.messages.listen(
    (message) {
      print('Mensaje recibido en el main: $message');
    },
    onError: (error) {
      print('Error recibido en el main: $error');
    },
    onDone: () {
      print('Conexión WebSocket cerrada');
    },
  );
 */
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => locator<SettingsBloc>()),
    BlocProvider(create: (_) => locator<RolesBloc>()),
    BlocProvider(create: (_) => locator<CompanyBloc>()),
    BlocProvider(create: (_) => locator<CountryBloc>()),
    BlocProvider(create: (_) => locator<UsersBloc>()),
    BlocProvider(create: (_) => locator<GeneralBloc>()),
    BlocProvider(create: (_) => locator<ProductsBloc>()),
    BlocProvider(create: (_) => locator<OrdersBloc>()),
    BlocProvider(create: (_) => locator<CommunicationBloc>()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        routerConfig: AppRoutes.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
        themeMode: ThemeMode.system,
        theme:
            context.watch<SettingsBloc>().state.currentTheme == ThemeMode.light
                ? AppTheme.light
                : AppTheme.dark,
        locale:
            Locale(context.watch<SettingsBloc>().state.currentLanguage.value),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ConnectivityListener(
            child: child!,
          );
        },
      ),
    );
  }
}
