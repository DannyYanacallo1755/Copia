import 'dart:convert';
import 'package:ourshop_ecommerce/models/available_currency.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class ChooseLanguagePage extends StatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage> {
  String? selectedLanguage;
  String? selectedCurrency;
  bool rememberChoice = false; // Variable para recordar la elección

  @override
  void initState() {
    super.initState();
    locator<Preferences>().saveLastVisitedPage('choose_language_page');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translation = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  text: translation.choose_language,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.black, 
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text.rich(
                  TextSpan(
                    text: translation.change_language_later,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
              ),
              
              // Lista de idiomas
              Expanded(
                child: ListView.builder(
                  itemCount: AvailableLanguages.availableLanguages.length,
                  itemBuilder: (context, index) {
                    final AvailableLanguages availableLanguage =
                        AvailableLanguages.availableLanguages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          return ListTile(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            title: Text(availableLanguage.name),
                            selected: state.selectedLanguage == availableLanguage.id,
                            selectedColor: theme.primaryColor,
                            selectedTileColor: AppTheme.palette[900]!.withOpacity(0.1),
                            leading: Image.network(
                              availableLanguage.flag,
                              width: 30,
                              height: 30,
                            ),
                            trailing: state.selectedLanguage == availableLanguage.id
                                ? Icon(Icons.check_circle, color: AppTheme.palette[950])
                                : null,
                            shape: state.selectedLanguage == availableLanguage.id
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: AppTheme.palette[1000]!, width: 1),
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                selectedLanguage = availableLanguage.id.toString();
                              });
                              context.read<SettingsBloc>().add(
                                ChangeSelectedLanguage(selectedLanguage: availableLanguage.id),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 15.0),
              Flexible(child: Text(translation.currency)),
              SizedBox(height: 15.0),

              // Lista de monedas
              Expanded(
                child: FutureBuilder<List<Currency>?>(
                  future: context.read<ProductsBloc>().getCurrency(),
                  builder: (BuildContext context, AsyncSnapshot<List<Currency>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          translation.error,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No currency',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final Currency currency = snapshot.data![index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: ListTile(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            title: Text(currency.name),
                            selected: selectedCurrency == currency.isoCode,
                            selectedColor: theme.primaryColor,
                            selectedTileColor: AppTheme.palette[800]!.withOpacity(0.1),
                            leading: Container(
                              width: 60,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.palette[1000]!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency.symbol,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            trailing: selectedCurrency == currency.isoCode
                                ? Icon(Icons.check_circle, color: AppTheme.palette[950])
                                : null,
                            shape: selectedCurrency == currency.isoCode
                                ? RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: AppTheme.palette[1000]!, width: 1),
                                  )
                                : null,
                            onTap: () async {
                              setState(() {
                                selectedCurrency = currency.isoCode;
                              });

                              // Guarda la moneda seleccionada en SharedPreferences
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              String jsonCurrency = jsonEncode(currency.toJson());
                              await prefs.setString('currency', jsonCurrency);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        if (selectedCurrency != null && selectedCurrency!.isNotEmpty) {
                          if (rememberChoice) {
                            locator<Preferences>().saveData('remember_choice', 'true');
                          }
                          context.go('/');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(translation.select_language_currency),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text(
                        translation.next,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
