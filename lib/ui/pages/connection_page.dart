import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class ConnectivityListener extends StatelessWidget {
  const ConnectivityListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocConsumer<GeneralBloc, GeneralState>(
        listener: (context, state) {
          if (!state.isInterentConnectionActive) {
            final  String message = translations.no_internet_connection;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (BuildContext context, GeneralState state) {
          if (state.isInterentConnectionActive) {
            return child;
          }
          return SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_connected_no_internet_4, size: 100, color: Colors.grey,),
                Text(translations.no_internet_connection, style:theme.textTheme.headlineLarge?.copyWith(color: Colors.grey),),
              ],
            ),
          );
        },
      ),
    );
  }
}