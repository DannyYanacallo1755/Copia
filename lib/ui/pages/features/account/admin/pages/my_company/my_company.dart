
import '../../../../../pages.dart';

enum BanKAccountType {
  Savings('SAVINGS'),
  Current('CURRENT');

  final String value;
  const BanKAccountType(this.value);
}

class ExpansionPanelItem {
  final CompanyBank bank;
  bool isExpanded;

  ExpansionPanelItem({
    required this.bank,
    this.isExpanded = false,
  });
}

class MyCompany extends StatefulWidget {

  const MyCompany({
    super.key,  
    required this.companyNameFormKey, 
    required this.generalFormKey, 
    required this.businessFormKey, 
    required this.socialMediaFormKey, 
    required this.bankFormKey
  });

  final GlobalKey<FormBuilderState> companyNameFormKey;
  final GlobalKey<FormBuilderState> generalFormKey;
  final GlobalKey<FormBuilderState> businessFormKey;
  final GlobalKey<FormBuilderState> socialMediaFormKey;
  final GlobalKey<FormBuilderState> bankFormKey;

  @override
  State<MyCompany> createState() => _MyCompanyState();
}

class _MyCompanyState extends State<MyCompany> with TickerProviderStateMixin {

  final List<String> tabs = [
    locator<AppLocalizations>().general,
    locator<AppLocalizations>().business,
    locator<AppLocalizations>().social_media,
    locator<AppLocalizations>().banks
  ];


  final List<int> qtyProductLandingPage = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  final List<BanKAccountType> accountTypes = [
    BanKAccountType.Savings,
    BanKAccountType.Current
  ];

  final List<Widget> _socialMediaForms = [];
  final ValueNotifier<List<ExpansionPanelItem>> _bankPanelsNotifier = ValueNotifier<List<ExpansionPanelItem>>([]);

  late ScrollController _scrollController;
  late FocusNode _focusNodeAddress;
  late FocusNode _focusNodePhone;
  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodeCountry;
  late FocusNode _focusNodeCountryCode;
  late FocusNode _focusNodeBusinessLine;
  late FocusNode _focusNodeTotalEmployees;
  late FocusNode _focusNodeWebsite;
  late FocusNode _focusNodeLegalOwner;

  late TabController _tabController;


  @override
  void initState() {
    context.read<CompanyBloc>().add(
      CompanyByIdEvent(
        companyId:context.read<UsersBloc>().state.loggedUser.companyId,
        countryId: context.read<UsersBloc>().state.loggedUser.companyCountryId
      )
    );
    _tabController = TabController(length: tabs.length, vsync: this)..addListener(listener);
    _scrollController = ScrollController();
    _focusNodeAddress = FocusNode();
    _focusNodePhone = FocusNode();
    _focusNodeEmail = FocusNode();
    _focusNodeCountry = FocusNode();
    _focusNodeCountryCode = FocusNode();
    _focusNodeBusinessLine = FocusNode();
    _focusNodeTotalEmployees = FocusNode();
    _focusNodeWebsite = FocusNode();
    _focusNodeLegalOwner = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _bankPanelsNotifier.dispose();
    _tabController.dispose();
    _tabController.removeListener(listener);
    _scrollController.dispose();
    _focusNodeAddress.dispose();
    _focusNodePhone.dispose();
    _focusNodeEmail.dispose();
    _focusNodeCountry.dispose();
    _focusNodeCountryCode.dispose();
    _focusNodeBusinessLine.dispose();
    _focusNodeTotalEmployees.dispose();
    _focusNodeWebsite.dispose();
    _focusNodeLegalOwner.dispose();
    super.dispose();
  }

  void listener() {
    if (_tabController.indexIsChanging) {
      context.read<CompanyBloc>().addSelectedCompanyForm(_tabController.index);
    }
  }

  void _addSocialMediaForm() {
    setState(() {
      _socialMediaForms.add(_buildSocialMediaFormWidget());
    });
  }

  void _addBankPanel() {
    _bankPanelsNotifier.value = List<ExpansionPanelItem>.from(_bankPanelsNotifier.value)
      ..add(ExpansionPanelItem(
        bank: CompanyBank(
          companyId: context.read<CompanyBloc>().state.userCompany.id,
          bankId: '',
          accountType: '',
          accountNumber: '',
          swiftCode: '',
          address: '',
          phoneNumber: '',
          intermediaryBankId: '', 
          id: '', 
          bankCountryId: '', 
          intermediaryBankCountryId: '',
          // showOrder: true,
        ),
        isExpanded: true,
      ));
  }

  void _removeBankPanel(int index) {
    _bankPanelsNotifier.value = List<ExpansionPanelItem>.from(_bankPanelsNotifier.value)
      ..removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? translations = AppLocalizations.of(context);
    return SizedBox(
      height: size.height,
      width: size.width,
      child: BlocBuilder<CompanyBloc, CompanyState>(
        buildWhen: (previous, current) => 
          previous.selectedMyCompanyFormIndex != current.selectedMyCompanyFormIndex 
          || previous.userCompany != current.userCompany 
          || previous.status != current.status
          || previous.logoStatus != current.logoStatus,

        builder: (context, state) {
          if (state.status == CompanyStateStatus.loading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (state.status == CompanyStateStatus.error) {
            return  Center(
              child: Text('Error loading company information', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),),
            );
          }
          if(state.userCompany.banks!.isNotEmpty) {
            _bankPanelsNotifier.value = state.userCompany.banks!.map((bank) => ExpansionPanelItem(bank: bank)).toList();
          }
          return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 10.0),
                      child: Text(translations!.update_prop(translations.company), style: theme.textTheme.titleLarge,),
                    )
                  ),
                  const SizedBox(height: 10.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    child: FormBuilder(
                      key: widget.companyNameFormKey,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            initialValue: state.userCompany.name,
                            style: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: translations.company_name,
                              hintText: translations.company_name,
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                          const SizedBox(height: 10.0,),
                          Container(
                            height: 200,
                            width: size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5.0),
                              image: state.selectedLogoPath.isNotEmpty && !state.userCompany.hasProfileImg
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(state.selectedLogoPath),)
                                  ) 
                                : state.userCompany.hasProfileImg 
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider('${dotenv.env['PRODUCT_URL']}company/${state.userCompany.id}/profile.png')
                                    )
                                  : null
                            ),
                            child: state.logoStatus == CompanyLogoStatus.loading 
                                    ? const Center(child: CircularProgressIndicator.adaptive())
                                    : state.selectedLogoPath.isNotEmpty || state.userCompany.hasProfileImg
                                      ? null
                                      : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.image, size: 50.0, color: Colors.grey,),
                                          Text(translations.company_logo_dimension, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),),
                                          Text(translations.supported_formats , style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),),
                                        ],
                                      )
                          ),
                          ElevatedButton(
                            onPressed: state.logoStatus == CompanyLogoStatus.loading || state.status == CompanyStateStatus.updating ? null : () => context.read<CompanyBloc>().chooseCompanyLogo(), 
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload, color: Colors.white,),
                                const SizedBox(width: 10.0,),
                                Text(translations.upload_logo, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    height: size.height,
                    width: double.maxFinite,
                    child: DefaultTabController(
                      length: tabs.length, 
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabAlignment: TabAlignment.center,
                            isScrollable: true,
                            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: _tabController.index,
                              children: [
                                _GeneralForm(
                                  focusNodeAddress: _focusNodeAddress, 
                                  focusNodePhone: _focusNodePhone, 
                                  theme: theme, 
                                  focusNodeEmail: _focusNodeEmail, 
                                  focusNodeCountry: _focusNodeCountry, 
                                  focusNodeCountryCode: _focusNodeCountryCode, 
                                  focusNodeBusinessLine: _focusNodeBusinessLine, 
                                  focusNodeTotalEmployees: _focusNodeTotalEmployees, 
                                  focusNodeWebsite: _focusNodeWebsite, 
                                  focusNodeLegalOwner: _focusNodeLegalOwner,
                                  formKey: widget.generalFormKey,
                                ),
                                _Business(
                                  businessKey: widget.businessFormKey,
                                  theme: theme, 
                                  qtyProductLandingPage: qtyProductLandingPage
                                ),
                                //social media
                                SingleChildScrollView(
                                  child: FormBuilder(
                                    key: widget.socialMediaFormKey,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: size.width,
                                          child: ElevatedButton(
                                            onPressed: _addSocialMediaForm,
                                            child: Text(translations.add_social_media, style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0,),
                                        ..._socialMediaForms
                                      ],
                                    ),
                                  ),
                                ),
                                // banks
                                SingleChildScrollView(
                                  child: FormBuilder(
                                    key: widget.bankFormKey,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: size.width,
                                          child: ElevatedButton(
                                            onPressed: _addBankPanel,
                                            child: Text(translations.add(translations.banks.split('s')[0]), style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0,),
                                        ValueListenableBuilder(
                                          valueListenable: _bankPanelsNotifier,
                                          builder: (BuildContext context, List<ExpansionPanelItem> value, Widget? child) {
                                            return ExpansionPanelList(
                                              elevation: 2.0,
                                              expansionCallback: (int index, bool isExpanded) {
                                                _bankPanelsNotifier.value = List<ExpansionPanelItem>.from(_bankPanelsNotifier.value)
                                                  ..[index].isExpanded = isExpanded;
                                              },
                                              children: value.map<ExpansionPanel>((ExpansionPanelItem item) {
                                                return ExpansionPanel(   
                                                  backgroundColor: Colors.white,                                         
                                                  headerBuilder: (BuildContext context, bool isExpanded) {
                                                    return ListTile(
                                                      shape: theme.inputDecorationTheme.border?.copyWith(borderSide: BorderSide.none),
                                                      title: Text(
                                                        item.bank.id.isEmpty 
                                                          ? 'New bank' 
                                                          : '${translations.country}: ${item.bank.bankCountryId.isNotEmpty ? context.read<CountryBloc>().state.countries.firstWhere((country) => country.id == item.bank.bankCountryId, orElse: () => const Country(id: '', name: 'Unknown', iso: '', iso3: '', numCode: 0, phoneCode: 0, flagUrl: '')).name : 'Unknown'} intermediate: ${item.bank.intermediaryBankId.isNotEmpty ? context.read<CountryBloc>().state.countries.firstWhere((country) => country.id == item.bank.intermediaryBankCountryId, orElse: () => const Country(id: '', name: 'Unknown', iso: '', iso3: '', numCode: 0, phoneCode: 0, flagUrl: '')).name : 'Unknown'} type: ${item.bank.accountType}',
                                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                                      ),
                                                    );
                                                  },
                                                  body: _buildBankFormWidget(value.indexOf(item)),
                                                  isExpanded: item.isExpanded,
                                                );
                                              }).toList(),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    )
                  )
                ],
              ),
            );
        },
      ),
    );
  }

  Widget _buildSocialMediaFormWidget() {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    return Row(
      children: [
        SizedBox(
          width: size.width * 0.4,
          child: FormBuilderDropdown(
            name: 'social_media_${_socialMediaForms.length}',
            style: theme.textTheme.labelLarge,
            decoration: InputDecoration(
              labelText: translations.social_media,
              hintText: translations.social_media,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]), 
            items: context.read<CompanyBloc>().state.socialMedias.map((socialMedia) => DropdownMenuItem(
              value: socialMedia.name,
              child: Text(socialMedia.name, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
            )).toList(),
          ),
        ),
        const SizedBox(width: 10.0,),
        SizedBox(
          width: size.width * 0.4,
          child: FormBuilderTextField(
            name: 'social_media_url_${_socialMediaForms.length}',
            style: theme.textTheme.labelLarge,
            decoration: InputDecoration(
              labelText: translations.social_media_url,
              hintText: translations.social_media_url,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _socialMediaForms.removeAt(_socialMediaForms.length - 1);
            });
          }, 
          icon: const Icon(Icons.delete)
        )
      ],
    );
  }

  Widget _buildBankFormWidget(int index){
    final CompanyBank bank = _bankPanelsNotifier.value[index].bank;
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 3.0,),
        FormBuilderDropdown(
          initialValue: context.read<CountryBloc>().state.countries.firstWhere(
              (country) => country.id == bank.bankCountryId,
              orElse: () => const Country(id: '', name: 'Unknown', iso: '', iso3: '', numCode: 0, phoneCode: 0, flagUrl: ''),
            ).id,
          name: 'countryId_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Choose country',
            hintText: 'Choose country',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]), 
          items: context.read<CountryBloc>().state.countries.map((country) => DropdownMenuItem(
            value: country.id,
            child: Text(country.name, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
          )).toList(),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderDropdown(
          initialValue: context.read<CompanyBloc>().state.banks.firstWhere((bank) => bank.id == bank.id).id,
          name: 'bankId_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Choose Bank',
            hintText: 'Bank Bank',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]), 
          items: context.read<CompanyBloc>().state.banks.map((country) => DropdownMenuItem(
            value: country.id,
            child: Text(country.name ?? 'no name', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
          )).toList(),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderDropdown(
          initialValue: bank.accountType,
          name: 'accountType_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Bank Account type',
            hintText: 'Bank Account type',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]), 
          items: accountTypes.map((accountType) => DropdownMenuItem(
            value: accountType.value,
            child: Text( accountType.value, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
          )).toList(),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderTextField(
          initialValue: bank.accountNumber,
          name: 'accountNumber_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: 'Account Number',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderTextField(
          initialValue: bank.address,
          name: 'address_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Bank Address',
            hintText: 'Bank Address',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderTextField(
          initialValue: bank.phoneNumber,
          name: 'phoneNumber_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Bank Phone Number',
            hintText: 'Bank Phone Number',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderTextField(
          initialValue: bank.swiftCode,
          name: 'swiftCode_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Bank Swift Code',
            hintText: 'Bank Swift Code',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderDropdown(
          initialValue: context.read<CountryBloc>().state.countries.firstWhere(
              (country) => country.id == bank.intermediaryBankCountryId,
              orElse: () => const Country(id: '', name: 'Unknown', iso: '', iso3: '', numCode: 0, phoneCode: 0, flagUrl: ''),
            ).id,
          name: 'intermediaryBankCountryId_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Choose country',
            hintText: 'Choose country',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]), 
          items: context.read<CountryBloc>().state.countries.map((country) => DropdownMenuItem(
            value: country.id,
            child: Text(country.name, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
          )).toList(),
        ),
        const SizedBox(height: 10.0,),
        FormBuilderDropdown(
          initialValue: context.read<CompanyBloc>().state.banks.firstWhere((bank) => bank.id == bank.id).id,
          name: 'intermediaryBankId_$index',
          style: theme.textTheme.labelLarge,
          decoration: const InputDecoration(
            labelText: 'Intermediary Bank',
            hintText: 'Intermediary Bank',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]), 
          items: context.read<CompanyBloc>().state.banks.map((bank) => DropdownMenuItem(
            value: bank.id,
            child: Text(bank.name ?? 'no bank name', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
          )).toList(),
        ),
        IconButton(
          onPressed: () => _removeBankPanel(index),
          icon: const Icon(Icons.delete)
        )
      ],
    );
  }
}

class _Business extends StatelessWidget {
  const _Business({
    required this.theme,
    required this.qtyProductLandingPage,
    required this.businessKey
  });

  final ThemeData theme;
  final List<int> qtyProductLandingPage;
  final GlobalKey<FormBuilderState> businessKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!; 
    return SingleChildScrollView(
      child: FormBuilder(
        key: businessKey,
        child: Column(
          children: [
            const SizedBox(height: 10.0,),
            FormBuilderDropdown(
              initialValue: context.read<ProductsBloc>().state.categories.firstWhere((category) => category.id == context.read<CompanyBloc>().state.userCompany.mainCategoryId, orElse: () => const Category(id: '', name: '', description: '', parentCategoryId: ''),).id,
              name: 'mainCategoryId',
              style: theme.textTheme.labelLarge,
              decoration: InputDecoration(
                labelText: translations.main_category,
                hintText: translations.main_category,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]), 
              items: context.read<ProductsBloc>().state.categories.map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black),),
              )).toList(),
            ),
            const SizedBox(height: 10.0,),
            FormBuilderDropdown(
              name: 'qtyProductLandingPage',
              style: theme.textTheme.labelLarge,
              decoration: InputDecoration(
                labelText: translations.products_landing_page,
                hintText: translations.products_landing_page,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]), 
              initialValue:context.read<CompanyBloc>().state.userCompany.qtyProductLandingPage,
              items: qtyProductLandingPage.map((qty) => DropdownMenuItem(
                value: qty,
                child: Text('$qty', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black)),
              )).toList(),
            ),
            const SizedBox(height: 10.0,),
            FormBuilderTextField(
              name: 'subdomain',
              style: theme.textTheme.labelLarge,
              initialValue:context.read<CompanyBloc>().state.userCompany.subdomain,
              decoration: InputDecoration(
                labelText: 'Subdomain',
                hintText: 'Subdomain',
                suffix: Text('.ourshop.shop', style: theme.textTheme.labelMedium?.copyWith(color: Colors.black),),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralForm extends StatelessWidget {
  _GeneralForm({
    required FocusNode focusNodeAddress,
    required FocusNode focusNodePhone,
    required this.theme,
    required FocusNode focusNodeEmail,
    required FocusNode focusNodeCountry,
    required FocusNode focusNodeCountryCode,
    required FocusNode focusNodeBusinessLine,
    required FocusNode focusNodeTotalEmployees,
    required FocusNode focusNodeWebsite,
    required FocusNode focusNodeLegalOwner, 
    required this.formKey,
  }) : 
  _focusNodeAddress = focusNodeAddress, 
  _focusNodePhone = focusNodePhone, 
  _focusNodeEmail = focusNodeEmail,
  _focusNodeCountry = focusNodeCountry, 
  _focusNodeCountryCode = focusNodeCountryCode, 
  _focusNodeBusinessLine = focusNodeBusinessLine, 
  _focusNodeTotalEmployees = focusNodeTotalEmployees, 
  _focusNodeWebsite = focusNodeWebsite, 
  _focusNodeLegalOwner = focusNodeLegalOwner;

  final FocusNode _focusNodeAddress;
  final FocusNode _focusNodePhone;
  final ThemeData theme;
  final FocusNode _focusNodeEmail;
  final FocusNode _focusNodeCountry;
  final FocusNode _focusNodeCountryCode;
  final FocusNode _focusNodeBusinessLine;
  final FocusNode _focusNodeTotalEmployees;
  final FocusNode _focusNodeWebsite;
  final FocusNode _focusNodeLegalOwner;

  final GlobalKey<FormBuilderState> formKey;
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FormBuilder(
        key: formKey,
        child: BlocBuilder<CompanyBloc, CompanyState>(
          buildWhen: (previous, current) => 
          previous.selectedMyCompanyFormIndex != current.selectedMyCompanyFormIndex 
          || previous.userCompany != current.userCompany 
          || previous.status != current.status,
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.address,
                  focusNode: _focusNodeAddress,
                  onEditingComplete: () => _focusNodePhone.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'address',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Address',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.phoneNumber,
                  focusNode: _focusNodePhone,
                  onEditingComplete: () => _focusNodeEmail.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'phoneNumber', 
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Phone',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.email,
                  focusNode: _focusNodeEmail,
                  onEditingComplete: () => _focusNodeCountry.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: "email", 
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                    
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderDropdown(
                  focusNode: _focusNodeCountry,
                  name: 'countryId',
                  initialValue: _getCountry(state, context),
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Country',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  items: context.read<CountryBloc>().state.countries.map((country) => DropdownMenuItem(
                    value: country.id,
                    child: Text(country.name),
                  )).toList(),
                  onChanged: (countryId) {
                    final Country country = context.read<CountryBloc>().state.getCountryById(countryId!);
                    _codeController.text = '+${country.numCode}';
                    _focusNodeCountryCode.requestFocus();
                  },
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  readOnly: true,
                  controller: _codeController,
                  focusNode: _focusNodeCountryCode,
                  onEditingComplete: () => _focusNodeBusinessLine.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'phoneNumberCode',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Country Code',
                    hintText: 'Country Code',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.advantages,
                  focusNode: _focusNodeBusinessLine,
                  onEditingComplete: () => _focusNodeTotalEmployees.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'advantages',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Business Line',
                    hintText: 'Business Line',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.totalEmployee.toString(),
                  focusNode: _focusNodeTotalEmployees,
                  onEditingComplete: () => _focusNodeWebsite.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'totalEmployee',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Office Size',
                    hintText: 'Office Size',
                  ),
                  validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]
                  ),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.websiteUrl,
                  focusNode: _focusNodeWebsite,
                  onEditingComplete: () => _focusNodeLegalOwner.requestFocus(),
                  textInputAction: TextInputAction.next,
                  name: 'websiteUrl',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    hintText: 'Website',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 10.0,),
                FormBuilderTextField(
                  initialValue: state.userCompany.legalOwner,
                  focusNode: _focusNodeLegalOwner,
                  textInputAction: TextInputAction.done,
                  name: 'legalOwner',
                  style: theme.textTheme.labelLarge,
                  decoration: const InputDecoration(
                    labelText: 'Legal Owner',
                    hintText: 'Legal Owner',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
              ]
            );
          },
        ),
      ),
    );
  }
    String _getCountry(CompanyState state , BuildContext context) {
      _codeController.text = '+${context.read<CountryBloc>().state.getCountryById(state.userCompany.countryId!).numCode}';
      return context.read<CountryBloc>().state.getCountryById(state.userCompany.countryId!).id;
    }
    

}