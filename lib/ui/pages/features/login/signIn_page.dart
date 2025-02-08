import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../pages.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;


class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final Color _cursorColor = AppTheme.palette[600]!;
  final double _space = 20;
  final ValueNotifier<bool> showPassword = ValueNotifier<bool>(true);
  late bool rememberMe;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().add(const AddRolesEvent());
    context.read<CountryBloc>().add(const AddCountriesEvent());
    locator<Preferences>().saveLastVisitedPage('sign_in_page');
    _userController = TextEditingController(
        text: locator<Preferences>().preferences['email'] ?? '');
    _passwordController = TextEditingController(
        text: locator<Preferences>().preferences['password'] ?? '');
    rememberMe = bool.parse(
        locator<Preferences>().preferences['remember_me'] ?? 'false');
  }

  @override
  void dispose() {
    super.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> hasPasswordError = ValueNotifier(false);
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final TextStyle inputValueStyle =
        theme.textTheme.bodyMedium!.copyWith(color: Colors.black);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/logos/logo_ourshop_1.png',
            height: 150,
            width: 150,
          ),
        ),
        body: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text.rich(TextSpan(
                    text: translations.welcome_to,
                    style: theme.textTheme.titleMedium,
                    children: [
                      TextSpan(
                          text: translations.ourshop,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: AppTheme.palette[800])),
                      TextSpan(
                          text: translations.e_commerce,
                          style: theme.textTheme.titleMedium),
                      TextSpan(
                          text: translations.app,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: AppTheme.palette[800])),
                    ])),
                SizedBox(
                  height: _space,
                ),
                Text.rich(TextSpan(
                    text: translations.slogan_1,
                    style: theme.textTheme.titleLarge,
                    children: [
                      TextSpan(
                        text: translations.slogan_2,
                        style: theme.textTheme.titleMedium,
                      ),
                    ])),
                const SizedBox(
                  height: 10,
                ),
                Text.rich(TextSpan(
                    text: translations.sing_in_your_account,
                    style: theme.textTheme.titleSmall,
                    children: [
                      TextSpan(
                          text: ' ${translations.to} ${translations.continue_}',
                          style: theme.textTheme.titleSmall)
                    ])),
                SizedBox(
                  height: _space,
                ),
                FormBuilder(
                    key: _formKey,
                    child: BlocConsumer<UsersBloc, UsersState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            FormBuilderTextField(
                              readOnly: state.status == UserStatus.loading,
                              autofocus: rememberMe ? false : true,
                              focusNode: _userFocusNode,
                              controller: _userController,
                              style: inputValueStyle,
                              onEditingComplete: () => rememberMe
                                  ? null
                                  : FocusScope.of(context)
                                      .requestFocus(_passwordFocusNode),
                              textInputAction: TextInputAction.next,
                              name: "username",
                              cursorColor: _cursorColor,
                              decoration: InputDecoration(
                                labelText: translations.username,
                                hintText: translations.placeholder(
                                    translations.username.toLowerCase()),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                            ),
                            SizedBox(
                              height: _space,
                            ),
                            ValueListenableBuilder(
                              valueListenable: showPassword,
                              builder: (BuildContext context, value, _) {
                                return FormBuilderTextField(
                                  readOnly: state.status == UserStatus.loading,
                                  focusNode: _passwordFocusNode,
                                  style: inputValueStyle,
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.send,
                                  onEditingComplete: () =>
                                      _formKey.currentState!.save(),
                                  onSubmitted: (_) => _doLogin(),
                                  name: "password",
                                  cursorColor: _cursorColor,
                                  decoration: InputDecoration(
                                      labelText: translations.password,
                                      hintText: translations.placeholder(
                                          translations.password.toLowerCase()),
                                      suffixIcon: IconButton(
                                        onPressed:
                                            state.status == UserStatus.loading
                                                ? null
                                                : () => showPassword.value =
                                                    !showPassword.value,
                                        icon: Icon(showPassword.value
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      )),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(6),
                                  ]),
                                  obscureText: value,
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onChanged: (val) {
                                    final isValid = _formKey
                                            .currentState?.fields['password']
                                            ?.validate() ??
                                        true;
                                    hasPasswordError.value = !isValid;
                                  },
                                );
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: hasPasswordError,
                              builder:
                                  (BuildContext context, bool hasError, _) {
                                return const SizedBox(height: 5.0);
                              },
                            ),
                            SizedBox(
                              height: 70.0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.4,
                                    child: IgnorePointer(
                                      ignoring:
                                          state.status == UserStatus.loading,
                                      child: FormBuilderCheckbox(
                                        shape: const RoundedRectangleBorder(
                                            side: BorderSide.none),
                                        initialValue: rememberMe,
                                        onChanged: (value) {
                                          if (!value!) {
                                            locator<Preferences>()
                                                .removeData('remember_me');
                                            locator<Preferences>()
                                                .removeData('username');
                                            locator<Preferences>()
                                                .removeData('password');
                                          }
                                          locator<Preferences>().saveData(
                                              'remember_me', value.toString());
                                        },
                                        name: "remember_me",
                                        title: Text(
                                          translations.remember_me,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.status == UserStatus.loading
                                    ? null
                                    : () => _doLogin(),
                                child: state.status == UserStatus.loading &&
                                        !_isLoading
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(
                                        translations.sign_in_with(
                                            translations.email.toLowerCase()),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF4285F4),
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Icon(FontAwesomeIcons.google),
                                label: _isLoading
                                    ? const Text("")
                                    : Text(
                                        translations.login_google,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        _doGoogleSignIn(translations);
                                      },
                              ),
                            ),
                          /*Boton Iniciar Sesion Apple*/
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Icon(FontAwesomeIcons.apple),
                                label: _isLoading
                                    ? const Text("")
                                    : Text(
                                        translations.login_apple,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        _doAppleSignIn(translations);
                                      },
                              ),
                            ),
                              /*-----------*/
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  translations.dont_have_account,
                                  style: theme.textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: state.status == UserStatus.loading
                                      ? null
                                      : () => context.push('/sign-up'),
                                  child: Text(
                                    translations.sign_up,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.palette[800],
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                      listener: (BuildContext context, UsersState state) {
                        if (state.status == UserStatus.logged &&
                            state.loggedUser.userId.isNotEmpty) {
                          context.go('/home');
                        }
                      },
                    ))
              ],
            ),
          ),
        ));
  }

  void _doLogin() {
    if (_formKey.currentState!.saveAndValidate()) {
      if (_formKey.currentState!.value['remember_me']) {
        locator<Preferences>()
            .saveData('username', _formKey.currentState!.value['username']);
        locator<Preferences>()
            .saveData('password', _formKey.currentState!.value['password']);
      }
      FocusScope.of(context).unfocus();
      context.read<UsersBloc>().add(Login(data: _formKey.currentState!.value));
    }
  }

  void _doGoogleSignIn(translations) {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    context
        .read<UsersBloc>()
        .add(LoginGoogle(data: _formKey.currentState!.value));

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
      });
      final currentState = context.read<UsersBloc>().state;

      if (currentState.status == UserStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.user_no_exist_description)),
        );
      }
    });
  }

  /*inicio de sesion con apple */
void _doAppleSignIn(AppLocalizations translations) async {
  setState(() {
    _isLoading = true;
  });

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // Enviar credenciales al Bloc
    context.read<UsersBloc>().add(LoginApple(data: {
      'identityToken': credential.identityToken,
      'authorizationCode': credential.authorizationCode,
    }));

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
      });

      final currentState = context.read<UsersBloc>().state;
      if (currentState.status == UserStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.user_no_exist_description)),
        );
      }
    });
  } catch (error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${translations.login_failed}: $error")),
    );
  }
}

}
