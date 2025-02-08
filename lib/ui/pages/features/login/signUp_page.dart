import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final double _space = 20;

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _phoneNumberCodeFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _companyFocusNode = FocusNode();
  final FocusNode _roleFocusNode = FocusNode();
  final Color _cursorColor = AppTheme.palette[600]!;

  late TextEditingController _codeController;
  late TextEditingController _companyController;

  final ValueNotifier<bool> showPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> showConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> showActiveView = ValueNotifier<bool>(false);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _companyController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _codeController.dispose();
    _companyController.dispose();

    //_usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneNumberCodeFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _companyFocusNode.dispose();
    _roleFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final TextEditingController _searchController = TextEditingController();
    late ValueNotifier<List<Country>> _filteredCountries;

    final TextTheme textS = Theme.of(context).textTheme;
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final TextStyle inputValueStyle =
        textS.bodyMedium!.copyWith(color: Colors.black);
    return ValueListenableBuilder(
      valueListenable: showActiveView,
      builder: (BuildContext context, bool value, _) {
        return Scaffold(
          appBar: !value
              ? AppBar(
                  title: Image.asset(
                  'assets/logos/logo_ourshop_1.png',
                  height: 150,
                  width: 150,
                ))
              : null,
          body: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(20),
            child: value
                ? _ActivateAccount(
                    translations: translations,
                    textS: textS,
                    showActiveView: showActiveView)
                : _FormView(
                    translations: translations,
                    textS: textS,
                    space: _space,
                    formKey: _formKey,
                    inputValueStyle: inputValueStyle,
                    usernameFocusNode: _usernameFocusNode,
                    emailFocusNode: _emailFocusNode,
                    cursorColor: _cursorColor,
                    passwordFocusNode: _passwordFocusNode,
                    showPassword: showPassword,
                    confirmPasswordFocusNode: _confirmPasswordFocusNode,
                    showConfirmPassword: showConfirmPassword,
                    nameFocusNode: _nameFocusNode,
                    lastNameFocusNode: _lastNameFocusNode,
                    phoneNumberFocusNode: _phoneNumberFocusNode,
                    codeController: _codeController,
                    size: size,
                    companyFocusNode: _companyFocusNode,
                    companyController: _companyController,
                    roleFocusNode: _roleFocusNode,
                    showActiveView: showActiveView,
                  ),
          ),
        );
      },
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.translations,
    required this.textS,
    required double space,
    required GlobalKey<FormBuilderState> formKey,
    required this.inputValueStyle,
    required FocusNode usernameFocusNode,
    required FocusNode emailFocusNode,
    required Color cursorColor,
    required FocusNode passwordFocusNode,
    required this.showPassword,
    required FocusNode confirmPasswordFocusNode,
    required this.showConfirmPassword,
    required FocusNode nameFocusNode,
    required FocusNode lastNameFocusNode,
    required FocusNode phoneNumberFocusNode,
    required TextEditingController codeController,
    required this.size,
    required FocusNode companyFocusNode,
    required TextEditingController companyController,
    required FocusNode roleFocusNode,
    required this.showActiveView,
  })  : _space = space,
        _formKey = formKey,
        _usernameFocusNode = usernameFocusNode,
        _emailFocusNode = emailFocusNode,
        _cursorColor = cursorColor,
        _passwordFocusNode = passwordFocusNode,
        _confirmPasswordFocusNode = confirmPasswordFocusNode,
        _nameFocusNode = nameFocusNode,
        _lastNameFocusNode = lastNameFocusNode,
        _phoneNumberFocusNode = phoneNumberFocusNode,
        _codeController = codeController,
        _companyFocusNode = companyFocusNode,
        _companyController = companyController;
  // _roleFocusNode = roleFocusNode;

  final AppLocalizations translations;
  final TextTheme textS;
  final double _space;
  final GlobalKey<FormBuilderState> _formKey;
  final TextStyle inputValueStyle;
  final FocusNode _usernameFocusNode;
  final FocusNode _emailFocusNode;
  final Color _cursorColor;
  final FocusNode _passwordFocusNode;
  final ValueNotifier<bool> showPassword;
  final FocusNode _confirmPasswordFocusNode;
  final ValueNotifier<bool> showConfirmPassword;
  final FocusNode _nameFocusNode;
  final FocusNode _lastNameFocusNode;
  final FocusNode _phoneNumberFocusNode;
  final TextEditingController _codeController;
  final Size size;
  final FocusNode _companyFocusNode;
  final TextEditingController _companyController;
  // final FocusNode _roleFocusNode;
  final ValueNotifier<bool> showActiveView;

  @override
  Widget build(BuildContext context) {
    void doGoogleSignIn() async {
      context.read<UsersBloc>().add(const RegisterGoogle());
      Future.delayed(const Duration(milliseconds: 2000), () {
        final currentState = context.read<UsersBloc>().state;
        if (currentState.status == UserStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translations.user_no_exist_description)),
          );
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                translations.sign_up,
                style: textS.titleLarge
                    ?.copyWith(fontSize: 25, fontWeight: FontWeight.w700),
              )),
          SizedBox(
            height: _space,
          ),
          FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  //FormBuilderTextField(
                    //style: inputValueStyle,
                    //autofocus: true,
                    //selectionHeightStyle: BoxHeightStyle.tight,
                    //selectionWidthStyle: BoxWidthStyle.tight,
                    //focusNode: _usernameFocusNode,
                    //onEditingComplete: () =>
                      //  FocusScope.of(context).requestFocus(_emailFocusNode),
                    //textInputAction: TextInputAction.next,
                    //name: "username",
                    //cursorColor: _cursorColor,
                    //decoration: InputDecoration(
                      //labelText: translations.username,
                      //hintText: translations
                        //  .placeholder(translations.username.toLowerCase()),
                    //),
                    //validator: FormBuilderValidators.compose([
                      //FormBuilderValidators.required(),
                    //]),
                    //autovalidateMode: AutovalidateMode.onUserInteraction,
                  //),
                  //SizedBox(
                    //height: _space,
                  //),
                  FormBuilderTextField(
                    style: inputValueStyle,
                    focusNode: _emailFocusNode,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    textInputAction: TextInputAction.next,
                    name: "email",
                    decoration: InputDecoration(
                      labelText: translations.email,
                      hintText: translations
                          .placeholder(translations.email.toLowerCase()),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  ValueListenableBuilder(
                    valueListenable: showPassword,
                    builder: (BuildContext context, value, _) {
                      return FormBuilderTextField(
                        style: inputValueStyle,
                        focusNode: _passwordFocusNode,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocusNode),
                        textInputAction: TextInputAction.next,
                        name: "password",
                        decoration: InputDecoration(
                          labelText: translations.password,
                          hintText: translations
                              .placeholder(translations.password.toLowerCase()),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              showPassword.value = !showPassword.value;
                            },
                          ),
                        ),
                        obscureText: value,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.hasSpecialChars(),
                          FormBuilderValidators.hasUppercaseChars(),
                          FormBuilderValidators.hasNumericChars(),
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      );
                    },
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  ValueListenableBuilder(
                    valueListenable: showConfirmPassword,
                    builder: (BuildContext context, value, _) {
                      return FormBuilderTextField(
                        style: inputValueStyle,
                        focusNode: _confirmPasswordFocusNode,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(_nameFocusNode),
                        textInputAction: TextInputAction.next,
                        name: "confirm_password",
                        autofillHints: const <String>[AutofillHints.password],
                        obscureText: value,
                        decoration: InputDecoration(
                          labelText: translations.confirm_password,
                          hintText: translations.confirm_password,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              showConfirmPassword.value =
                                  !showConfirmPassword.value;
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          (val) {
                            final password = _formKey
                                .currentState?.fields['password']?.value;
                            if (val != password) {
                              return translations.conform_password_error;
                            }
                            return null;
                          },
                        ]),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      );
                    },
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  FormBuilderTextField(
                    style: inputValueStyle,
                    focusNode: _nameFocusNode,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_lastNameFocusNode),
                    textInputAction: TextInputAction.next,
                    name: "name",
                    decoration: InputDecoration(
                      labelText: translations.name,
                      hintText: translations
                          .placeholder(translations.name.toLowerCase()),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  FormBuilderTextField(
                    style: inputValueStyle,
                    focusNode: _lastNameFocusNode,
                    onEditingComplete: () => FocusScope.of(context)
                        .requestFocus(_phoneNumberFocusNode),
                    textInputAction: TextInputAction.next,
                    name: "lastName",
                    decoration: InputDecoration(
                      labelText: translations.last_name,
                      hintText: translations
                          .placeholder(translations.last_name.toLowerCase()),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  FormBuilderDropdown(
                      name: "countryId",
                      decoration: InputDecoration(
                          labelText: translations.country,
                          hintText: translations.choose_country),
                      items: context
                          .watch<CountryBloc>()
                          .state
                          .countries
                          .map((Country country) => DropdownMenuItem(
                                value: country.id,
                                child: Row(
                                  children: [
                                    FlagPhoto(
                                      country: country,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        country.name,
                                        style: textS.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (countryId) {
                        final Country country = context
                            .read<CountryBloc>()
                            .state
                            .getCountryById(countryId!);
                        _codeController.text = '+${country.phoneCode}';
                      }),
                  SizedBox(
                    height: _space,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.2,
                        child: FormBuilderTextField(
                          controller: _codeController,
                          name: "phoneNumberCode",
                          decoration: InputDecoration(
                            hintText: translations.phoneNumberCode,
                          ),
                          style:
                              textS.bodyMedium?.copyWith(color: Colors.black),
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.01,
                      ),
                      Expanded(
                        child: FormBuilderTextField(
                          style: inputValueStyle,
                          focusNode: _phoneNumberFocusNode,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_companyFocusNode),
                          textInputAction: TextInputAction.next,
                          name: "phoneNumber",
                          decoration: InputDecoration(
                            labelText: translations.phone_number,
                            hintText: translations.placeholder(
                                translations.phone_number.toLowerCase()),
                          ),
                          keyboardType: TextInputType.number,
                          autofillHints: const <String>[
                            AutofillHints.telephoneNumber
                          ],
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.phoneNumber(),
                          ]),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  BlocBuilder<RolesBloc, RolesState>(
                    builder: (context, state) {
                      return FormBuilderCheckboxGroup<String>(
                        name: "rolesIds",
                        onChanged: (roles) {
                          if (state.selectedRoles
                              .contains(state.sellerRole.id)) {
                            _companyController.clear();
                          }
                          context.read<RolesBloc>().addSelectedRoles(roles!);
                        },
                        decoration: InputDecoration(
                            labelText: translations.role,
                            hintText: translations.choose_role),
                        validator: FormBuilderValidators.required(),
                        options: state.roles
                            .map((Role role) => FormBuilderFieldOption(
                                  value: role.id,
                                  child: Text(
                                    role.name,
                                    style: textS.bodySmall,
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  BlocBuilder<RolesBloc, RolesState>(
                    builder: (context, state) {
                      if (!state.selectedRoles.contains(state.sellerRole.id)) {
                        return const SizedBox();
                      }
                      return FormBuilderTextField(
                        controller: _companyController,
                        style: inputValueStyle,
                        focusNode: _companyFocusNode,
                        name: "companyName",
                        decoration: InputDecoration(
                            labelText: translations.company,
                            hintText: translations.company),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      );
                    },
                  ),
                  SizedBox(
                    height: _space,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<UsersBloc, UsersState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: context
                                  .read<UsersBloc>()
                                  .generalBloc
                                  .state
                                  .isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!
                                      .saveAndValidate()) {
                                    context.read<UsersBloc>().add(
                                        RegisterNewUser(
                                            data:
                                                _formKey.currentState!.value));
                                  }
                                },
                          child: state.status == UserStatus.registering
                              ? CircularProgressIndicator.adaptive(
                                  backgroundColor: AppTheme.palette[550],
                                )
                              : Text(
                                  translations.sign_up,
                                  style: textS.labelMedium,
                                ),
                        );
                      },
                      listenWhen: (previous, current) =>
                          previous.status != current.status,
                      listener: (BuildContext context, UsersState state) {
                        switch (state.status) {
                          case UserStatus.registered:
                            SuccessToast(
                              title: AppLocalizations.of(context)!.suceess,
                              description:
                                  AppLocalizations.of(context)!.user_registered,
                              style: ToastificationStyle.flatColored,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green.shade500,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ).showToast(context);
                            showActiveView.value = true;
                            break;
                          default:
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: BlocConsumer<UsersBloc, UsersState>(
                      builder: (context, state) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4285F4),
                          ),
                          icon: context
                                  .read<UsersBloc>()
                                  .generalBloc
                                  .state
                                  .isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Icon(FontAwesomeIcons.google),
                          onPressed: context
                                  .read<UsersBloc>()
                                  .generalBloc
                                  .state
                                  .isLoading
                              ? null
                              : () => doGoogleSignIn(),
                          label: Text(
                            translations.sign_google,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                   
                      },
                      listenWhen: (previous, current) =>
                          previous.status != current.status,
                      listener: (BuildContext context, UsersState state) {
                        switch (state.status) {
                          case UserStatus.logged:
                            SuccessToast(
                              title: AppLocalizations.of(context)!.suceess,
                              description:
                                  AppLocalizations.of(context)!.user_registered,
                              style: ToastificationStyle.flatColored,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green.shade500,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ).showToast(context);
                            break;
                          default:
                        }
                      },
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

class _ActivateAccount extends StatelessWidget {
  const _ActivateAccount({
    required this.translations,
    required this.textS,
    required this.showActiveView,
  });

  final AppLocalizations translations;
  final TextTheme textS;
  final ValueNotifier<bool> showActiveView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            translations.activate_account,
            style: textS.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            translations.activate_account_description,
            style: textS.bodyMedium?.copyWith(color: Colors.grey.shade400),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            child: Text(
              translations.done,
              style: textS.labelMedium,
            ),
          ),
        ),
      ],
    );
  }
}
