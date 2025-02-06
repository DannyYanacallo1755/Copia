import 'dart:developer';
import '../../../ui/pages/pages.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final Dio dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({required this.dio});

  Future<dynamic> loginApple(Map<String, dynamic> data) async {
    try {
      // Obtén las credenciales de Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Prepara los datos para enviar al backend
      final requestBody = jsonEncode({
        "data": {
          "user": {
            "uid": credential.userIdentifier, // Identificador único de Apple
            "email": credential.email, // Correo electrónico (si está disponible)
            "displayName":
                "${credential.givenName} ${credential.familyName}", // Nombre completo
            "isAnonymous": false,
            "photoURL": null, // Apple no proporciona una URL de foto
            "providerData": [
              {
                "providerId": "apple.com",
                "uid": credential.userIdentifier,
                "displayName":
                    "${credential.givenName} ${credential.familyName}",
                "email": credential.email,
                "phoneNumber": null,
                "photoURL": null
              }
            ],
            "stsTokenManager": {
              "refreshToken": credential.authorizationCode,
              "accessToken": credential.identityToken,
              "expirationTime": DateTime.now()
                  .add(Duration(days: 30))
                  .millisecondsSinceEpoch, // Simula una expiración
            },
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "lastLoginAt": DateTime.now().millisecondsSinceEpoch,
            "apiKey": "AIzaSyCRIC2zDjrHoKZkKK2x1ehaDij8Va0Lrig", // Clave de API de Firebase
            "appName": "APP"
          },
          "providerId": "apple.com",
          "operationType": "signIn",
          "_tokenResponse": {
            "federatedId": "https://appleid.apple.com/${credential.userIdentifier}",
            "providerId": "apple.com",
            "emailVerified": credential.email != null,
            "firstName": credential.givenName,
            "fullName": "${credential.givenName} ${credential.familyName}",
            "lastName": credential.familyName,
            "photoUrl": null,
            "localId": credential.userIdentifier,
            "displayName": "${credential.givenName} ${credential.familyName}",
            "idToken": credential.identityToken,
            "context": "",
            "oauthAccessToken": credential.authorizationCode,
          }
        }
      });

      // Envía los datos al backend
      final response = await http.post(
        Uri.parse('${dotenv.env['ADMIN_API_URL']}/auth/apple-login'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final auth = Authentication.fromJson(responseBody);
        locator<Preferences>().saveData('token', auth.data.token);
        locator<Preferences>().saveData('refreshToken', auth.data.refreshToken);
        final LoggedUser loggedUser =
            LoggedUser.fromJson(auth.data.getTokenPayload);
        return loggedUser;
      } else {
        print('Error en el login con Apple: ${response.body}');
        throw Exception('Error en el login con Apple');
      }
    } catch (e) {
      print('Se produjo un error al autenticarse con Apple: $e');
      throw Exception('Error al autenticarse con Apple');
    }
  }


  Future<dynamic> login(Auth data) async {
    try {
      final response = await dio.post('/auth/login', data: data.login());
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
            // Aquí puedes manejar el error o crear un nuevo usuario si es necesario
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

  Future<dynamic> register(NewUser data) async {
    try {
      final response =
          await dio.post('/auth/register', data: data.newUserToJson());
      final user = UserResponse.fromJson(response.data);
      return user.data;
    } on DioException catch (e) {
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
