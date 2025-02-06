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
  String? selectedCurrencys;
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
              Text.rich(TextSpan(
                text: translation.choose_language,
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w700),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text.rich(TextSpan(
                  text: translation.change_language_later,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                )),
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: AvailableLanguages.availableLanguages.length,
                itemBuilder: (context, index) {
                  final AvailableLanguages availbaleLanguage =
                      AvailableLanguages.availableLanguages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        return ListTile(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          title: Text(availbaleLanguage.name),
                          selected:
                              state.selectedLanguage == availbaleLanguage.id,
                          selectedColor: theme.primaryColor,
                          selectedTileColor:
                              AppTheme.palette[900]!.withOpacity(0.1),
                          leading: Image.network(
                            availbaleLanguage.flag,
                            width: 30,
                            height: 30,
                          ),
                          trailing:
                              state.selectedLanguage == availbaleLanguage.id
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppTheme.palette[950],
                                    )
                                  : null,
                          shape: state.selectedLanguage == availbaleLanguage.id
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: AppTheme.palette[1000]!, width: 1))
                              : null,
                          onTap: () {
                            setState(() {
                              selectedLanguage =
                                  availbaleLanguage.id.toString();
                            });
                            context.read<SettingsBloc>().add(
                                ChangeSelectedLanguage(
                                    selectedLanguage: availbaleLanguage.id));
                            locator<Preferences>().saveData('language', availbaleLanguage.id.toString());
                          },
                        );
                      },
                    ),
                  );
                },
              )),
              SizedBox(height: 15.0),
              Flexible(child: Text(translation.currency)),
              SizedBox(height: 15.0),
              Expanded(
                child: FutureBuilder<List<Currency>?>(
                  future: context.read<ProductsBloc>().getCurrency(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Currency>?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          translation.error,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.black),
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

                    // Variable para almacenar el currency seleccionado temporalmente.
                    String? selectedCurrency;

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
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
                                selectedTileColor:
                                    AppTheme.palette[800]!.withOpacity(0.1),
                                leading: Container(
                                  width: 60,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.palette[1000]!
                                        .withOpacity(0.1),
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
                                    ? Icon(
                                        Icons.check_circle,
                                        color: AppTheme.palette[950],
                                      )
                                    : null,
                                shape: selectedCurrency == currency.isoCode
                                    ? RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color: AppTheme.palette[1000]!,
                                            width: 1),
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedCurrencys = currency.isoCode;
                                    selectedCurrency = currency.isoCode;
                                  });
                                  String jsonCurrency =
                                      jsonEncode(currency.toJson());

                                  locator<Preferences>().saveData('currency', jsonCurrency);
                                },
                              ),
                            );
                          },
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
                        if (selectedCurrencys != null &&
                            selectedCurrencys!.isNotEmpty) {
                          context.go('/');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(translation.select_language_currency),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text(
                        translation.next,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
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
