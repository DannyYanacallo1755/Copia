import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Importa el paquete para Apple Sign In
import '../../pages.dart';

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
        text: locator<Preferences>().preferences['username'] ?? '');
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

  // Método para manejar el inicio de sesión con Apple
  Future<void> _doAppleSignIn() async {
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

      // Aquí puedes manejar la credencial de Apple, por ejemplo, enviarla a tu backend
      print(credential);

      // Simula un inicio de sesión exitoso
      context.read<UsersBloc>().add(LoginApple(data: {
        'appleId': credential.userIdentifier,
        'email': credential.email,
        'fullName': credential.givenName,
      }));

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión con Apple: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> hasPasswordError = ValueNotifier(false);
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final TextStyle inputValueStyle =
        theme.textTheme.bodyMedium!.copyWith(color: Colors.black);
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
                    text: 'Welcome to',
                    style: theme.textTheme.titleMedium,
                    children: [
                      TextSpan(
                          text: ' OurShop',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: AppTheme.palette[800])),
                      TextSpan(
                          text: ' E-Commerce',
                          style: theme.textTheme.titleMedium),
                      TextSpan(
                          text: ' App',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: AppTheme.palette[800])),
                    ])),
                SizedBox(
                  height: _space,
                ),
                Text.rich(TextSpan(
                    text: 'Slogan 1',
                    style: theme.textTheme.titleLarge,
                    children: [
                      TextSpan(
                        text: ' Slogan 2',
                        style: theme.textTheme.titleMedium,
                      ),
                    ])),
                const SizedBox(
                  height: 10,
                ),
                Text.rich(TextSpan(
                    text: 'Sign in to your account',
                    style: theme.textTheme.titleSmall,
                    children: [
                      TextSpan(
                          text: ' to continue',
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
                                labelText: 'Username',
                                hintText: 'Enter your username',
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
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
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
                                          'Remember me',
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
                                        'Sign in with Email',
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
                                        'Login with Google',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        _doGoogleSignIn();
                                      },
                              ),
                            ),
                            // Botón de inicio de sesión con Apple
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black, // Color de Apple
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
                                    : const Icon(FontAwesomeIcons.apple),
                                label: _isLoading
                                    ? const Text("")
                                    : Text(
                                        'Login with Apple',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                onPressed: _isLoading ? null : _doAppleSignIn,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: theme.textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: state.status == UserStatus.loading
                                      ? null
                                      : () => context.push('/sign-up'),
                                  child: Text(
                                    'Sign up',
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

  void _doGoogleSignIn() {
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
          SnackBar(content: Text('User does not exist')),
        );
      }
    });
  }
}