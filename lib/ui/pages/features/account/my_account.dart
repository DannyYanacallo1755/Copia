import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:ourshop_ecommerce/services/admin/auth/account_service.dart';
import 'package:ourshop_ecommerce/ui/pages/features/account/buyer/orders_page.dart';
import '../../../../models/available_currency.dart';
import '../../pages.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _translateAnimation;
  late Animation<double> _opacityAnimation;
  late AnimationController _componentAnimationController;
  String? selectedCurrencys;
  late Animation<double> _avatarButtonTranslation;

  void listener() {
    if (_scrollController.position.pixels >= 58.0) {
      _animationController.forward();
    } else if (_scrollController.position.pixels < 58.0) {
      _animationController.reverse();
    }
  }

  void animationControllerListener() {
    _translateAnimation.addListener(() {
      if (_translateAnimation.value == 50.0) {
        _componentAnimationController.forward();
      } else if (_translateAnimation.value == 0.0) {
        _componentAnimationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _componentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _translateAnimation = Tween<double>(begin: 0.0, end: 50.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _avatarButtonTranslation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _componentAnimationController, curve: Curves.linear));

    _scrollController.addListener(listener);
    _animationController.addListener(animationControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _scrollController.removeListener(listener);
    _animationController.dispose();
    _animationController.removeListener(animationControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final loggedUser = context.watch<UsersBloc>().state.loggedUser;

    final personalInformationTextTheme =
        theme.textTheme.labelMedium?.copyWith(color: Colors.grey.shade500);

    void showBottomSheet(BuildContext context, SettingsOptionsMode mode) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          switch (mode) {
            case SettingsOptionsMode.Language:
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
                child: Column(
                  children: [
                    Text(
                      translations.change_your_language,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
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
                                  selected: state.selectedLanguage ==
                                      availbaleLanguage.id,
                                  selectedColor: theme.primaryColor,
                                  selectedTileColor:
                                      AppTheme.palette[900]!.withOpacity(0.1),
                                  leading: Image.network(
                                    availbaleLanguage.flag,
                                    width: 30,
                                    height: 30,
                                  ),
                                  trailing: state.selectedLanguage ==
                                          availbaleLanguage.id
                                      ? Icon(
                                          Icons.check_circle,
                                          color: AppTheme.palette[950],
                                        )
                                      : null,
                                  shape: state.selectedLanguage ==
                                          availbaleLanguage.id
                                      ? RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                              color: AppTheme.palette[1000]!,
                                              width: 1))
                                      : null,
                                  onTap: () {
                                    context.read<SettingsBloc>().add(
                                        ChangeSelectedLanguage(
                                            selectedLanguage:
                                                availbaleLanguage.id));
                                    locator<Preferences>().saveData('language',
                                        availbaleLanguage.id.toString());
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            case SettingsOptionsMode.Currency:
              return Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    translations.change_your_currency,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: FutureBuilder<List<Currency>?>(
                      future: context.read<ProductsBloc>().getCurrency(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Currency>?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              translations.error,
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
                        String? selectedCurrency;
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final Currency currency = snapshot.data![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: ListTile(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    title: Text(currency.name),
                                    selected:
                                        selectedCurrency == currency.isoCode,
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    trailing:
                                        selectedCurrency == currency.isoCode
                                            ? Icon(
                                                Icons.check_circle,
                                                color: AppTheme.palette[950],
                                              )
                                            : null,
                                    shape: selectedCurrency == currency.isoCode
                                        ? RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                                color: AppTheme.palette[1000]!,
                                                width: 1),
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        selectedCurrency = currency.isoCode;
                                      });
                                      String jsonCurrency =
                                          jsonEncode(currency.toJson());

                                      locator<Preferences>()
                                          .saveData('currency', jsonCurrency);
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
                ],
              );

            default:
              return Container(
                height: size.height * 0.50,
                color: Colors.white,
                child: const Center(
                  child: Text('This is a Bottom Sheet'),
                ),
              );
          }
        },
      );
    }

    final List<SettignsOptions> personalInformation = [
      SettignsOptions(
          title: translations.name,
          mode: SettingsOptionsMode.Name,
          // onClick: () => showBottomSheet(context),
          onClick: () => null,
          data: Text(loggedUser.name.toUpperCase(),
              style: personalInformationTextTheme)),
      SettignsOptions(
          title: translations.last_name,
          mode: SettingsOptionsMode.LastName,
          // onClick: () => showBottomSheet(context),
          onClick: () => null,
          data: Text(loggedUser.lastName.toUpperCase(),
              style: personalInformationTextTheme)),
      SettignsOptions(
          title: translations.email,
          mode: SettingsOptionsMode.Email,
          // onClick: () => showBottomSheet(context),
          onClick: () => null,
          data: Text(loggedUser.email, style: personalInformationTextTheme)),
      SettignsOptions(
          title: translations.phone,
          mode: SettingsOptionsMode.Phone,
          // onClick: () => showBottomSheet(context),
          onClick: () => null,
          data: Text(
              '${loggedUser.userPhoneNumberCode} ${loggedUser.userPhoneNumber}',
              style: personalInformationTextTheme)),
      SettignsOptions(
          title: translations.country,
          mode: SettingsOptionsMode.Phone,
          // onClick: () => showBottomSheet(context),
          onClick: () => null,
          data: Text(loggedUser.userCountryName,
              style: personalInformationTextTheme)),
    ];

    final List<SettignsOptions> orderHistory = [
      SettignsOptions(
        title: translations.all_orders,
        mode: SettingsOptionsMode.AllOrders,
        // onClick: () => showBottomSheet(context)
        onClick: () => null,
      ),
      SettignsOptions(
        title: translations.processing,
        mode: SettingsOptionsMode.Processing,
        // onClick: () => showBottomSheet(context)
        onClick: () => null,
      ),
      SettignsOptions(
        title: translations.shipped,
        mode: SettingsOptionsMode.Shipped,
        // onClick: () => showBottomSheet(context)
        onClick: () => null,
      ),
      SettignsOptions(
        title: translations.delivered,
        mode: SettingsOptionsMode.Delivered,
        // onClick: () => showBottomSheet(context)
        onClick: () => null,
      ),
      SettignsOptions(
        title: translations.cancelled,
        mode: SettingsOptionsMode.Cancelled,
        // onClick: () => showBottomSheet(context)
        onClick: () => null,
      ),
      SettignsOptions(
        title: translations.returned,
        mode: SettingsOptionsMode.Returned,
        // onClick: () => showBottomSheet(context)
        onClick: () {},
      ),
    ];

    final List<SettignsOptions> settings = [
      // SettignsOptions(
      //   title: translations.deliver_to,
      //   mode: SettingsOptionsMode.Deliver,
      //   onClick: () => null,
      // ),
      // SettignsOptions(
      //   title: translations.currency,
      //   mode: SettingsOptionsMode.Currency,
      //   onClick: () => null,
      // ),

      SettignsOptions(
          title: translations.language,
          mode: SettingsOptionsMode.Language,
          onClick: () => showBottomSheet(context, SettingsOptionsMode.Language)
          // onClick: () => null,
          ),
      SettignsOptions(
          title: translations.currency,
          mode: SettingsOptionsMode.Currency,
          onClick: () => showBottomSheet(context, SettingsOptionsMode.Currency)
          // onClick: () => null,
          ),
      if (loggedUser.roles.toLowerCase().split(', ').contains('seller'))
        SettignsOptions(
            title: translations.admin,
            mode: SettingsOptionsMode.Language,
            onClick: () => context.push('/admin')),
      if (loggedUser.roles.toLowerCase().split(', ').contains('buyer'))
        SettignsOptions(
            title: translations.orders,
            mode: SettingsOptionsMode.Language,
            onClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerOrdes()),
              );
            }),
      SettignsOptions(
          title: translations.logout,
          mode: SettingsOptionsMode.Logout,
          onClick: () {}),
    ];

    List<AccountOptions> sections = [
      AccountOptions(
          label: translations.personal_information,
          mode: AccountOptionsMode.PersonalInformation,
          sectionOptions: personalInformation,
          labelIcon: IconButton(
            style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                visualDensity: VisualDensity.compact,
                iconSize: const WidgetStatePropertyAll(15.0),
                backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300)),
            onPressed: () async {
              final LoggedUser loggedUser =
                  context.read<UsersBloc>().state.loggedUser;
              await PersonalInformationDialog(initialData: {
                'name': loggedUser.name,
                'lastName': loggedUser.lastName,
                'email': loggedUser.email,
                'phoneNumberCode': loggedUser.userPhoneNumberCode,
                'phoneNumber': loggedUser.userPhoneNumber,
                'countryId': loggedUser.userCountryId,
                // "rolesIds": [loggedUser.roles],
              }).showAlertDialog(context, translations, theme);
            },
            icon: const Icon(Icons.edit_rounded, color: Colors.grey),
          )),
      // AccountOptions(
      //   label: translations.shipping_address,
      //   mode: AccountOptionsMode.ShippingAddress,
      //   sectionOptions: const [],
      //   labelIcon: IconButton(
      //     style: ButtonStyle(
      //       splashFactory: NoSplash.splashFactory,
      //       visualDensity: VisualDensity.compact,
      //       iconSize: const WidgetStatePropertyAll(15.0),
      //       backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300)
      //     ),
      //     onPressed: () async {
      //       await ShippingAddressDialog(
      //         type: ShippingAddressDialogType.ADD
      //       ).showAlertDialog(context, translations, theme);
      //     },
      //     icon: const Icon(Icons.add, color: Colors.grey)
      //   )
      // ),

      // AccountOptions(
      //   label: translations.payment_methods,
      //   mode: AccountOptionsMode.PaymentMethods,
      //   sectionOptions: const [],
      //   labelIcon: IconButton(
      //     style: ButtonStyle(
      //       splashFactory: NoSplash.splashFactory,
      //       visualDensity: VisualDensity.compact,
      //       iconSize: const WidgetStatePropertyAll(15.0),
      //       backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300)
      //     ),
      //     onPressed: () {

      //     },
      //     icon: const Icon(Icons.add, color: Colors.grey)
      //   )
      // ),
      // AccountOptions(
      //   label: translations.order_history,
      //   mode: AccountOptionsMode.OrderHistory,
      //   sectionOptions: orderHistory,
      //   labelIcon: IconButton(
      //     style: ButtonStyle(
      //       splashFactory: NoSplash.splashFactory,
      //       visualDensity: VisualDensity.compact,
      //       iconSize: const WidgetStatePropertyAll(15.0),
      //       backgroundColor: WidgetStatePropertyAll(Colors.grey.shade100)
      //     ),
      //     onPressed: null,
      //     icon: Icon(Icons.add, color:Colors.grey.shade100)
      //   )
      // ),
      AccountOptions(
          label: translations.settings,
          mode: AccountOptionsMode.Settings,
          sectionOptions: settings,
          labelIcon: IconButton(
              style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  visualDensity: VisualDensity.compact,
                  iconSize: const WidgetStatePropertyAll(15.0),
                  backgroundColor:
                      WidgetStatePropertyAll(Colors.grey.shade100)),
              onPressed: null,
              icon: Icon(Icons.add, color: Colors.grey.shade100))),
    ];

    return Container(
        color: Colors.grey.shade100,
        height: double.maxFinite,
        width: double.maxFinite,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              leadingWidth: double.maxFinite,
              expandedHeight: 50.0,
              floating: false,
              pinned: true,
              leading: AnimatedBuilder(
                animation: Listenable.merge(
                    [_animationController, _componentAnimationController]),
                builder: (BuildContext context, Widget? child) {
                  if (_translateAnimation.isCompleted) {
                    return Transform.translate(
                        offset: Offset(0.0, _avatarButtonTranslation.value),
                        child: const _AvatarButton());
                  }
                  return Transform.translate(
                      offset: Offset(0.0, _translateAnimation.value * -1),
                      child: Opacity(
                          opacity: _opacityAnimation.value, child: child));
                },

                child: Text(
                  '${translations.role}: ${loggedUser.roles}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.black),
                ),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: SizedBox(
                //     width: size.width * 0.5,
                //     child: Autocomplete(
                //       initialValue: TextEditingValue.empty,
                //       displayStringForOption: (country) => country.name,
                //       fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                //         return ColoredBox(
                //           color: Colors.white,
                //           child: Align(
                //             alignment: Alignment.center,
                //             child: TextField(
                //               controller: textEditingController,
                //               focusNode: focusNode,
                //               onTapOutside: (event) => focusNode.unfocus(),
                //               style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.palette[1000]),
                //               decoration: InputDecoration(
                //                 prefixIcon: Icon(Icons.search, color: Colors.grey.shade700,),
                //                 contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                //                 hintText: translations.search,
                //                 hintStyle: theme.textTheme.labelMedium?.copyWith(color: Colors.grey.shade600),
                //                 border: InputBorder.none,
                //                 enabledBorder: InputBorder.none,
                //                 focusedBorder: InputBorder.none,
                //                 errorBorder: InputBorder.none,
                //                 disabledBorder: InputBorder.none,

                //               ),
                //             ),
                //           ),
                //         );
                //       },
                //       optionsViewBuilder: (context, onSelected, options) {
                //         return Material(
                //           elevation: 4.0,
                //           child: ListView.separated(
                //             shrinkWrap: true,
                //             itemCount: options.length,
                //             itemBuilder: (BuildContext context, int index) {
                //               final Country option = options.toList()[index];
                //               return ListTile(
                //                 selected: false,
                //                 tileColor: Colors.white,
                //                 shape: theme.listTileTheme.copyWith(
                //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))
                //                 ).shape,
                //                 title: Text(option.name, style: theme.textTheme.titleMedium,),
                //                 trailing: Text(option.iso3, style: theme.textTheme.labelLarge,),
                //                 leading: CircleAvatar(
                //                   backgroundImage: NetworkImage('${dotenv.env['FLAG_URL']}${option.flagUrl}'),
                //                 ),
                //                 onTap: () => onSelected(option),
                //               );
                //             }, separatorBuilder: (BuildContext context, int index)  => Divider(
                //                 height: 0.0,
                //                 indent: 15.0,
                //                 endIndent: 15.0,
                //                 color: Colors.grey.shade300,
                //               )
                //           ),
                //         );
                //       },
                //       optionsBuilder: (textEditingValue) {
                //         final List<Country> currencies = List.from(context.read<CountryBloc>().state.countries);
                //         return currencies.where((element) => (element.name.trim().toLowerCase().startsWith(textEditingValue.text) || element.iso3.trim().toLowerCase().startsWith(textEditingValue.text))).toList();
                //       },
                //       onSelected: (value){},
                //     ),
                //   ),
                //  ),
              ),
              //actions: [
              // Text('Role: ${loggedUser.roles}', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black),),
              //],
            ),
            SliverToBoxAdapter(
                child: Container(
              height: 60.0,
              color: Colors.white,
              child: const _AvatarButton(),
            )),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final AccountOptions accountSections = sections[index];
                  return _AccountSecction(
                    accountSections: accountSections,
                    theme: theme,
                    size: size,
                    translations: translations,
                  );
                },
                childCount: sections.length,
              ),
            ),
          ],
        ));
  }
}

class _AccountSecction extends StatelessWidget {
  const _AccountSecction({
    required this.accountSections,
    required this.theme,
    required this.size,
    required this.translations,
  });

  final AccountOptions accountSections;
  final ThemeData theme;
  final Size size;
  final AppLocalizations translations;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 5,
          right: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  accountSections.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (accountSections.labelIcon != null)
                  accountSections.labelIcon!,
              ],
            ),
          ),
        ),
        Container(
          height: size.height * 0.30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
          ),
          width: size.width,
          margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children:
                  _renderList(accountSections.mode, context, translations),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _renderList(AccountOptionsMode mode, BuildContext context,
      AppLocalizations translations) {
    switch (mode) {
      case AccountOptionsMode.ShippingAddress:
        if (context.read<UsersBloc>().state.shippingAddresses.isEmpty) {
          return [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: Text(
                  translations.no_shipping_methods,
                  style: theme.textTheme.titleMedium,
                )))
          ];
        }
        return context.read<UsersBloc>().state.shippingAddresses.map((address) {
          return Column(
            children: [
              RadioListTile(
                  selected: false,
                  tileColor: Colors.white,
                  shape: theme.listTileTheme
                      .copyWith(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0)))
                      .shape,
                  secondary: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit,
                        size: 15,
                        color: Colors.grey,
                      )),
                  title: Text(address.fullName),
                  subtitle: Text(
                      '${address.address}, ${address.municipality}, ${address.state}, ${address.country}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 10.0)),
                  value: address.id,
                  groupValue: context
                      .read<UsersBloc>()
                      .state
                      .selectedShippingAddress
                      .id,
                  onChanged:
                      (value) {} //context.read<UsersBloc>().addSelectedShippingAddress(ShippingAddress.shippingAddresses.firstWhere((element) => element.id == value)),
                  ),
              const Divider(
                indent: 30,
                endIndent: 30,
              )
            ],
          );
        }).toList();
      case AccountOptionsMode.PaymentMethods:
        if (context.read<UsersBloc>().state.cards.isEmpty) {
          return [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: Text(
                  translations.no_payment_methods,
                  style: theme.textTheme.titleMedium,
                )))
          ];
        }
        return context.watch<UsersBloc>().state.cards.map((card) {
          return Column(
            children: [
              RadioListTile(
                value: card.id,
                groupValue: context.read<UsersBloc>().state.selectedCard.id,
                onChanged: (value) {},
                title: Align(
                    alignment: Alignment.centerRight,
                    child: Text(card.cardNumber,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12.0))),
                subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Text('exp ${card.expirationDate}',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 10.0))),
              ),
              const Divider(
                indent: 30,
                endIndent: 30,
              )
            ],
          );
        }).toList();

      default:
        return accountSections.sectionOptions.map((SettignsOptions option) {
          if (option.mode == SettingsOptionsMode.Logout) {
            return Column(
              children: [
                SizedBox(
                  width: size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        await prefs.remove('username');
                        await prefs.remove('password');
                        await prefs.remove('remember_me');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChooseLanguagePage()),
                        );
                      },
                      child: Text(
                        translations.logout,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: SizedBox(
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              translations.confirm_delete_account,
                              textAlign: TextAlign.justify,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              translations.delete_account_warning,
                              textAlign: TextAlign.justify,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  translations.cancel,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final LoggedUser loggedUser = context
                                      .read<UsersBloc>()
                                      .state
                                      .loggedUser;
                                  deleteAccount(
                                      loggedUser.email,
                                      translations.delete_account_success,
                                      context,
                                      translations);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 160, 24, 15)),
                                child: Text(
                                  translations.delete,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.white),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      child: Text(
                        translations.delete_account,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            );
          }

          return ListTile(
            selected: false,
            tileColor: Colors.white,
            titleTextStyle: theme.textTheme.labelMedium
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
            shape: theme.listTileTheme
                .copyWith(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0)))
                .shape,
            title: Text(option.title),
            onTap: () => option.onClick(),
            trailing: option.data ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey, size: 15.0),
          );
        }).toList();
    }
  }
}

void deleteAccount(String email, deleteAccountSuccess, context,
    AppLocalizations translations) async {
  const String keyPassword = 'password';
  late SharedPreferences preferences;
  preferences = await SharedPreferences.getInstance();
  String? password = preferences.getString(keyPassword);
  final dio = Dio();
  final accountService = AccountService(dio: dio);
  final response = await accountService.deleteAccount(
      email, password!, context, translations);

  if (response.isNotEmpty) {
    Fluttertoast.showToast(
      msg: deleteAccountSuccess,
      gravity: ToastGravity.BOTTOM,
    );
    await preferences.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  } else {
    Fluttertoast.showToast(
      msg: "Error",
      gravity: ToastGravity.BOTTOM,
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocBuilder<UsersBloc, UsersState>(
      buildWhen: (previous, current) =>
          previous.loggedUser != current.loggedUser,
      builder: (context, state) {
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                    '${state.loggedUser.name[0].toUpperCase()}${state.loggedUser.lastName[0]}',
                    style: theme.textTheme.labelLarge),
              ),
            ),
            Text(
              state.loggedUser.name,
              style: theme.textTheme.labelLarge,
            ),
          ],
        );
      },
    );
  }
}

class AccountOptions extends Equatable {
  final String label;
  final Widget? labelIcon;
  final List<SettignsOptions> sectionOptions;
  final AccountOptionsMode mode;

  const AccountOptions({
    required this.label,
    required this.sectionOptions,
    this.labelIcon,
    required this.mode,
  });

  AccountOptions copyWith({
    String? label,
    List<SettignsOptions>? sectionOptions,
    Widget? labelIcon,
    AccountOptionsMode? mode,
  }) {
    return AccountOptions(
      label: label ?? this.label,
      sectionOptions: sectionOptions ?? this.sectionOptions,
      labelIcon: labelIcon ?? this.labelIcon,
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object?> get props => [
        label,
        sectionOptions,
        labelIcon,
        mode,
      ];
}

class SettignsOptions {
  final String title;
  final SettingsOptionsMode mode;
  final Function onClick;
  final Widget? data;

  const SettignsOptions(
      {required this.title,
      required this.mode,
      required this.onClick,
      this.data});
}

enum SettingsOptionsMode {
  Language,
  Currency,
  Deliver,
  AllOrders,
  Processing,
  Shipped,
  Delivered,
  Cancelled,
  Returned,
  Name,
  LastName,
  Email,
  Phone,
  Country,
  Admin,
  Logout,
  DeleteAccount
}

enum AccountOptionsMode {
  PersonalInformation,
  ShippingAddress,
  PaymentMethods,
  OrderHistory,
  Settings,
}
