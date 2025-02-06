import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../domain/admin/blocs/Users/users_bloc.dart'; // Asegúrate de importar tu archivo de Bloc
import '../../ui/pages/pages.dart';

class AuthServiceFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthServiceFirebase();

  Future<void> handleSignIn(context) async {
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
          print('Login exitoso');
          context.read<UsersBloc>().add(Login(data: requestBody));
          /* final response = await http.post(
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

            locator<Preferences>()
                .saveData('token', responseBody['data']['token']);
            locator<Preferences>()
                .saveData('refreshToken', responseBody['data']['refreshToken']);
           
          } else {
            print('Error en el login: ${response.body}');
            // Aquí puedes manejar el error o crear un nuevo usuario si es necesario
          } */
        }
      }
    } catch (e) {
      print('Se produjo un error al authenticarse $e');
    }
  }

  Future handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesion $e");
    }
  }
}
