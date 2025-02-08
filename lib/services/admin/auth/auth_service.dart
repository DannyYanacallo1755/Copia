import 'dart:developer';
import '../../../ui/pages/pages.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/*Agregado*/
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart'; 


class AuthService {
  final Dio dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({required this.dio});

  Future<dynamic> login(Auth data) async {
    try {
      final response = await dio.post('/auth/login',
          data: data.login());
      final auth = Authentication.fromJson(response.data);
      locator<Preferences>().saveData('token', auth.data.token);
      locator<Preferences>().saveData('refreshToken', auth.data.refreshToken);
      final LoggedUser loggedUser =
          LoggedUser.fromJson(auth.data.getTokenPayload);
      return loggedUser;
    } on DioException catch (e) {
      log('AuthService -> : ${e.response?.data}');
      ErrorHandler(e);
    }
  }

  Future<dynamic> loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          final refreshToken = await user.getIdToken(true);
          final requestBody = jsonEncode({
            "data": {
              "user": {
                "uid": user.uid,
                "emailVerified": user.emailVerified,
                "displayName": user.displayName,
                "isAnonymous": user.isAnonymous,
                "photoURL": user.photoURL,
                "providerData": user.providerData.map((provider) {
                  return {
                    "providerId": provider.providerId,
                    "uid": provider.uid,
                    "displayName": provider.displayName,
                    "email": provider.email,
                    "phoneNumber": provider.phoneNumber,
                    "photoURL": provider.photoURL
                  };
                }).toList(),
              },
              "stsTokenManager": {
                "refreshToken": refreshToken,
                "accessToken": googleSignInAuthentication.accessToken,
                "expirationTime":
                    user.metadata.lastSignInTime?.millisecondsSinceEpoch
              },
              "createdAt": user.metadata.creationTime?.millisecondsSinceEpoch,
              "lastLoginAt":
                  user.metadata.lastSignInTime?.millisecondsSinceEpoch,
              "apiKey": "AIzaSyCRIC2zDjrHoKZkKK2x1ehaDij8Va0Lrig",
              "appName": "APP"
            },
            "providerId": "google.com",
            "operationType": "signIn",
            "_tokenResponse": {
              "federatedId": "https://accounts.google.com/${user.uid}",
              "providerId": "google.com",
              "emailVerified": user.emailVerified,
              "firstName": user.displayName?.split(" ").first,
              "fullName": user.displayName,
              "lastName": user.displayName?.split(" ").last,
              "photoUrl": user.photoURL,
              "localId": user.uid,
              "displayName": user.displayName,
              "idToken": googleSignInAuthentication.idToken,
              "context": "",
              "oauthAccessToken": googleSignInAuthentication.accessToken,
            }
          });
          final response = await http.post(
            Uri.parse('${dotenv.env['ADMIN_API_URL']}/auth/firebase-login'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          );
          if (response.statusCode == 200) {
            var responseBody = json.decode(response.body);
            final auth = Authentication.fromJson(responseBody);
            locator<Preferences>().saveData('token', auth.data.token);
            locator<Preferences>()
                .saveData('refreshToken', auth.data.refreshToken);
            final LoggedUser loggedUser =
                LoggedUser.fromJson(auth.data.getTokenPayload);
            return loggedUser;
          } else {
            var requestBody = jsonEncode({
              "data": {
                "user": {
                  "uid": user.uid,
                  "emailVerified": user.emailVerified,
                  "displayName": user.displayName,
                  "isAnonymous": user.isAnonymous,
                  "photoURL": user.photoURL,
                  "providerData": user.providerData.map((provider) {
                    return {
                      "providerId": provider.providerId,
                      "uid": provider.uid,
                      "displayName": provider.displayName,
                      "email": provider.email,
                      "phoneNumber": provider.phoneNumber,
                      "photoURL": provider.photoURL
                    };
                  }).toList(),
                  "stsTokenManager": {
                    "refreshToken": refreshToken,
                    "accessToken": googleSignInAuthentication.accessToken,
                    "expirationTime":
                        user.metadata.lastSignInTime?.millisecondsSinceEpoch
                  },
                  "createdAt":
                      user.metadata.creationTime?.millisecondsSinceEpoch,
                  "lastLoginAt":
                      user.metadata.lastSignInTime?.millisecondsSinceEpoch,
                  "apiKey": "AIzaSyCRIC2zDjrHoKZkKK2x1ehaDij8Va0Lrig",
                  "appName": "APP",
                },
                "_tokenResponse": {
                  "federatedId": "https://accounts.google.com/${user.uid}",
                  "providerId": "google.com",
                  "emailVerified": user.emailVerified,
                  "firstName": user.displayName?.split(" ").first,
                  "fullName": user.displayName,
                  "lastName": user.displayName?.split(" ").last,
                  "photoUrl": user.photoURL,
                  "localId": user.uid,
                  "displayName": user.displayName,
                  "idToken": googleSignInAuthentication.idToken,
                  "context": "",
                  "oauthAccessToken": googleSignInAuthentication.accessToken,
                },
                "providerId": "google.com",
                "operationType": "signIn"
              },
              "countryId": "d296f2b0-b3b1-4676-805e-85225b65dc4f"
            });

            final response = await http.post(
              Uri.parse(
                  '${dotenv.env['ADMIN_API_URL']}/auth/firebase-register'),
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            );
            if (response.statusCode == 200) {
              var responseBody = json.decode(response.body);
              final auth = Authentication.fromJson(responseBody);
              locator<Preferences>().saveData('token', auth.data.token);
              locator<Preferences>()
                  .saveData('refreshToken', auth.data.refreshToken);
              final LoggedUser loggedUser =
                  LoggedUser.fromJson(auth.data.getTokenPayload);
              return loggedUser;
            } else {
              print('Error en el login: ${response.body}');
              // Aquí puedes manejar el error o crear un nuevo usuario si es necesario
            }
            // Aquí puedes manejar el error o crear un nuevo usuario si es necesario
          }
        }
      }
    } 
    catch (e) {
      if (kDebugMode) {
        print('Se produjo un error al authenticarse $e');
      }
    }
    /*  try {
      final response = await dio.post('/auth/firebase-login', data: data());
      final auth = Authentication.fromJson(response.data);
      locator<Preferences>().saveData('token', auth.data.token);
      locator<Preferences>().saveData('refreshToken', auth.data.refreshToken);
      final LoggedUser loggedUser =
          LoggedUser.fromJson(auth.data.getTokenPayload);
      return loggedUser;
    } on DioException catch (e) {
      log('AuthService -> : ${e.response?.data}');
      ErrorHandler(e);
    } */
  }



/*Para rl inicio de sesion con apple */

Future<dynamic> loginApple() async {
  try {
    // Verifica si es un dispositivo iOS o macOS
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)) {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final authCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(authCredential);
      final user = userCredential.user;

      if (user != null) {
        final refreshToken = await user.getIdToken(true);
        final requestBody = jsonEncode({
          "data": {
            "user": {
              "uid": user.uid,
              "emailVerified": user.emailVerified,
              "displayName": user.displayName,
              "isAnonymous": user.isAnonymous,
              "photoURL": user.photoURL,
              "providerData": user.providerData.map((provider) {
                return {
                  "providerId": provider.providerId,
                  "uid": provider.uid,
                  "displayName": provider.displayName,
                  "email": provider.email,
                  "phoneNumber": provider.phoneNumber,
                  "photoURL": provider.photoURL
                };
              }).toList(),
            },
            "stsTokenManager": {
              "refreshToken": refreshToken,
              "idToken": credential.identityToken,
              "accessToken": credential.authorizationCode,
            },
            "createdAt": user.metadata.creationTime?.millisecondsSinceEpoch,
            "lastLoginAt": user.metadata.lastSignInTime?.millisecondsSinceEpoch,
          },
          "providerId": "apple.com",
          "operationType": "signIn",
        });

        final response = await http.post(
          Uri.parse('${dotenv.env['ADMIN_API_URL']}/auth/firebase-login'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        if (response.statusCode == 200) {
          var responseBody = json.decode(response.body);
          final auth = Authentication.fromJson(responseBody);
          locator<Preferences>().saveData('token', auth.data.token);
          locator<Preferences>().saveData('refreshToken', auth.data.refreshToken);
          final LoggedUser loggedUser = LoggedUser.fromJson(auth.data.getTokenPayload);
          return loggedUser;
        }
      }
    } else {
      throw Exception("Apple Sign In solo funciona en iOS o macOS");
    }
  } catch (e) {
    print('Error en el inicio de sesión con Apple: $e');
    return null;
  }
}
/* ------------------------- */
  Future<dynamic> registerGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          final refreshToken = await user.getIdToken(true);
          var requestBody = jsonEncode({
            "data": {
              "user": {
                "uid": user.uid,
                "emailVerified": user.emailVerified,
                "displayName": user.displayName,
                "isAnonymous": user.isAnonymous,
                "photoURL": user.photoURL,
                "providerData": user.providerData.map((provider) {
                  return {
                    "providerId": provider.providerId,
                    "uid": provider.uid,
                    "displayName": provider.displayName,
                    "email": provider.email,
                    "phoneNumber": provider.phoneNumber,
                    "photoURL": provider.photoURL
                  };
                }).toList(),
                "stsTokenManager": {
                  "refreshToken": refreshToken,
                  "accessToken": googleSignInAuthentication.accessToken,
                  "expirationTime":
                      user.metadata.lastSignInTime?.millisecondsSinceEpoch
                },
                "createdAt": user.metadata.creationTime?.millisecondsSinceEpoch,
                "lastLoginAt":
                    user.metadata.lastSignInTime?.millisecondsSinceEpoch,
                "apiKey": "AIzaSyCRIC2zDjrHoKZkKK2x1ehaDij8Va0Lrig",
                "appName": "APP",
              },
              "_tokenResponse": {
                "federatedId": "https://accounts.google.com/${user.uid}",
                "providerId": "google.com",
                "emailVerified": user.emailVerified,
                "firstName": user.displayName?.split(" ").first,
                "fullName": user.displayName,
                "lastName": user.displayName?.split(" ").last,
                "photoUrl": user.photoURL,
                "localId": user.uid,
                "displayName": user.displayName,
                "idToken": googleSignInAuthentication.idToken,
                "context": "",
                "oauthAccessToken": googleSignInAuthentication.accessToken,
              },
              "providerId": "google.com",
              "operationType": "signIn"
            },

            "countryId":
                "d296f2b0-b3b1-4676-805e-85225b65dc4f" //cambiar de acuerdo a pantalla
          });

          final response = await http.post(
            Uri.parse('${dotenv.env['ADMIN_API_URL']}/auth/firebase-register'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          );
          if (response.statusCode == 200) {
            var responseBody = json.decode(response.body);
            final auth = Authentication.fromJson(responseBody);
            locator<Preferences>().saveData('token', auth.data.token);
            locator<Preferences>()
                .saveData('refreshToken', auth.data.refreshToken);
            final LoggedUser loggedUser =
                LoggedUser.fromJson(auth.data.getTokenPayload);
            return loggedUser;
          } else {
            print('Error en el login: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('Se produjo un error al authenticarse $e');
    }
    /*  try {
      final response = await dio.post('/auth/firebase-login', data: data());
      final auth = Authentication.fromJson(response.data);
      locator<Preferences>().saveData('token', auth.data.token);
      locator<Preferences>().saveData('refreshToken', auth.data.refreshToken);
      final LoggedUser loggedUser =
          LoggedUser.fromJson(auth.data.getTokenPayload);
      return loggedUser;
    } on DioException catch (e) {
      log('AuthService -> : ${e.response?.data}');
      ErrorHandler(e);
    } */
  }

  Future<dynamic> register1(NewUser data) async {
    try {
      final response = await dio.post( 
          '/auth/register', 
          data: data.newUserToJson()
      );
      final user = UserResponse.fromJson(response.data);
      return user.data;
    } on DioException catch (e) {
      ErrorHandler(e);
    }
  }

  Future<dynamic> register(NewUser data) async {
  try {
    // Obtener la URL base y el Referer desde el .env
    final String? envUrl = dotenv.env['ENV_URL'];

    final response = await dio.post(
      '/auth/register', // Se asegura de usar BASE_URL
      data: data.newUserToJson(),
      options: Options(
        headers: {
          'Referer': envUrl ?? '', // Si REFERER está vacío, lo deja como string vacío
          'Content-Type': 'application/json', // Asegura que el tipo de contenido sea JSON
        },
      ),
    );

    final user = UserResponse.fromJson(response.data);
    return user.data;
  } on DioException catch (e) {
    log("Error en register: ${e.response?.data}");
    ErrorHandler(e);
  }
}

  Future<void> refreshToken(String refreshToken) async {
    try {
      log('dio: ${dio.options.baseUrl}/auth/refresh-token');
      log('refer: ${dio.options.headers['Referer']}');
      final response = await dio.post('/auth/refresh-token',
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}));
      log('response :${response.data}');

      // return {
      //   'accessToken': newToken,
      //   'refreshToken': newRefreshToken,
      // };
    } on DioException catch (e) {
      log('refreshToken exception: ${e.response?.data}');
    }
  }
}
