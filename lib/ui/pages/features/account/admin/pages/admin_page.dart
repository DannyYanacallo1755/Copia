import '../../../../pages.dart';
import 'my_company/my_company.dart';

class AdminOption {
  final String title;
  final List<String> subCategories;
  final bool isExpanded;

  AdminOption({
    required this.title,
    this.subCategories = const [],
    this.isExpanded = false,
  });

  static List<AdminOption> options = [
    AdminOption(
      title: locator<AppLocalizations>().my_company,
      subCategories: [
        locator<AppLocalizations>().company_profile,
        locator<AppLocalizations>().web_editor,
      ],
    ),
    AdminOption(title: locator<AppLocalizations>().orders, subCategories: [
      locator<AppLocalizations>().orders_list,
    ]),
    AdminOption(title: locator<AppLocalizations>().products, subCategories: [
      locator<AppLocalizations>().include_products,
      locator<AppLocalizations>().countries_group,
      locator<AppLocalizations>().shipping_cost,
      locator<AppLocalizations>().offers,
    ]),
    AdminOption(
        title: locator<AppLocalizations>().comunication,
        subCategories: [
          locator<AppLocalizations>().comunication,
        ]),
  ];
}

extension AdminOptionExtension on AdminOptions {
  String get title {
    switch (this) {
      case AdminOptions.MY_COMPANY:
        return 'My Company';
      case AdminOptions.ORDERS:
        return 'Orders';
      case AdminOptions.PRODUCTS:
        return 'Products';
      case AdminOptions.COMMUNICATION:
        return 'Communication';
      default:
        return '';
    }
  }
}

class AdminPage extends StatelessWidget {
  AdminPage({super.key});

  final ValueNotifier<List<bool>> expanded = ValueNotifier<List<bool>>(
    List<bool>.generate(AdminOption.options.length, (index) => false),
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? translations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.palette[1000],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppTheme.palette[1000],
        title: Text(
          translations!.admin_page,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: ValueListenableBuilder(
            valueListenable: expanded,
            builder: (BuildContext context, List<bool> value, Widget? child) {
              return ExpansionPanelList(
                animationDuration: const Duration(milliseconds: 500),
                expandIconColor: Colors.white,
                dividerColor: AppTheme.palette[550],
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (int index, bool isExpanded) {
                  expanded.value = List<bool>.from(expanded.value)
                    ..[index] = isExpanded;
                },
                children: AdminOption.options.map((AdminOption option) {
                  return ExpansionPanel(
                    backgroundColor: AppTheme.palette[950],
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        shape: theme.inputDecorationTheme.border
                            ?.copyWith(borderSide: BorderSide.none),
                        title: Text(
                          option.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                    body: Column(
                      children: option.subCategories.map((subCategory) {
                        return ListTile(
                          shape: theme.inputDecorationTheme.border
                              ?.copyWith(borderSide: BorderSide.none),
                          title: Text(subCategory,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white)),
                          onTap: () {
                            if (subCategory ==
                                locator<AppLocalizations>().company_profile) {
                              context.push('/admin/option/my-company',
                                  extra: AdminOptions.MY_COMPANY);
                            } else if (subCategory ==
                                locator<AppLocalizations>().web_editor) {
                              context
                                  .push('/admin/option/my-company/WebEditor');
                            } else if (subCategory ==
                                locator<AppLocalizations>().orders_list) {
                              context.push('/admin/option/orders',
                                  extra: AdminOptions.ORDERS);
                            } else if (subCategory ==
                                locator<AppLocalizations>().include_products) {
                              context.push('/admin/option/products',
                                  extra: AdminOptions.PRODUCTS);
                            } else if (subCategory ==
                                locator<AppLocalizations>().countries_group) {
                              context.push(
                                  '/admin/option/products/countries-groups');
                            } else if (subCategory ==
                                locator<AppLocalizations>().shipping_cost) {
                              context.push(
                                  '/admin/option/products/shipping-rates');
                            } else if (subCategory ==
                                locator<AppLocalizations>().offers) {
                              context.push('/admin/option/products/offers');
                            } else if (subCategory ==
                                locator<AppLocalizations>().comunication) {
                              context.push('/admin/option/communication',
                                  extra: AdminOptions.COMMUNICATION);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    isExpanded: value[AdminOption.options.indexOf(option)],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminOptionPage extends StatelessWidget {
  AdminOptionPage({super.key, required this.option});

  final AdminOptions option;

  final GlobalKey<FormBuilderState> _companyNameFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _generalFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _businessFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _socialMediaFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _bankFormKey =
      GlobalKey<FormBuilderState>();

  String _getTitle(AdminOptions option, BuildContext context, translations) {
    switch (option) {
      case AdminOptions.MY_COMPANY:
        return option.title;
      case AdminOptions.ORDERS:
        return '${translations.orders} - ${context.watch<OrdersBloc>().state.adminOrders.length}';
      case AdminOptions.PRODUCTS:
        return option.title;
      case AdminOptions.COMMUNICATION:
        return 'Communication';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? translations = AppLocalizations.of(context);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            _getTitle(option, context, translations),
            style: const TextStyle(
                color: Color(0xff003049),
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            if (option == AdminOptions.PRODUCTS)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/admin/option/products/new',
                    extra: AdminOptions.PRODUCTS),
              )
          ],
        ),
        body: Builder(builder: (context) {
          switch (option) {
            case AdminOptions.MY_COMPANY:
              return MyCompany(
                companyNameFormKey: _companyNameFormKey,
                generalFormKey: _generalFormKey,
                businessFormKey: _businessFormKey,
                socialMediaFormKey: _socialMediaFormKey,
                bankFormKey: _bankFormKey,
              );
            case AdminOptions.ORDERS:
              return const AdminOrders();
            case AdminOptions.PRODUCTS:
              return const AdminProducts();
            case AdminOptions.COMMUNICATION:
              return const AdminCommunicationPage();
            default:
              return SizedBox(
                child: Center(
                  child: Text(
                    'No option selected',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
          }
        }),
        floatingActionButton: (option == AdminOptions.MY_COMPANY)
            ? BlocBuilder<CompanyBloc, CompanyState>(
                builder: (context, state) {
                  return CustomFloatingActionButton(
                    onClick: state.status == CompanyStateStatus.updating
                        ? null
                        : () {
                            if (_companyNameFormKey.currentState!.saveAndValidate() &&
                                _generalFormKey.currentState!
                                    .saveAndValidate() &&
                                _businessFormKey.currentState!
                                    .saveAndValidate() &&
                                _socialMediaFormKey.currentState!
                                    .saveAndValidate() &&
                                _bankFormKey.currentState!.saveAndValidate()) {
                              final Map<String, dynamic> company =
                                  _companyNameFormKey.currentState!.value;
                              final Map<String, dynamic> general =
                                  _generalFormKey.currentState!.value;
                              final Map<String, dynamic> business =
                                  _businessFormKey.currentState!.value;
                              final Map<String, dynamic> socialMedia =
                                  _socialMediaFormKey.currentState!.value;
                              final Map<String, dynamic> banksData =
                                  _bankFormKey.currentState!.value;

                              final List<Map<String, dynamic>> cleanedBanks =
                                  [];

                              // Limpiar claves dinámicas de los bancos
                              banksData.forEach((key, value) {
                                final bankIndex = key.split('_').last;
                                if (cleanedBanks.length <=
                                    int.parse(bankIndex)) {
                                  cleanedBanks.add({});
                                }
                                final cleanedKey =
                                    key.replaceAll(RegExp(r'_\d+$'), '');
                                cleanedBanks[int.parse(bankIndex)][cleanedKey] =
                                    value;
                              });

                              // Crear el objeto final
                              final Map<String, dynamic> data = {
                                ...company,
                                ...general,
                                ...business,
                                "socialMedias":
                                    socialMedia.isNotEmpty ? [socialMedia] : [],
                                "banks": cleanedBanks
                              };

                              context.read<CompanyBloc>().add(
                                    UpdateCompanyInformationEvent(
                                      companyId: context
                                          .read<UsersBloc>()
                                          .state
                                          .loggedUser
                                          .companyId,
                                      uppdatedInfo: data,
                                    ),
                                  );
                            }
                          },
                    child: state.status == CompanyStateStatus.updating
                        ? const CircularProgressIndicator.adaptive()
                        : const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                  );
                },
              )
            : null);
  }

  Map<String, dynamic> cleanKeys(Map<String, dynamic> data) {
    final Map<String, dynamic> cleanedMap = {};

    data.forEach((key, value) {
      final cleanedKey = key.replaceAll(RegExp(r'_\d+$'), '');
      cleanedMap[cleanedKey] = value;
    });

    return cleanedMap;
  }
}
