import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../pages.dart';

class WebEditor extends StatefulWidget {
  const WebEditor({super.key});

  @override
  State<WebEditor> createState() => _WebEditorState();
}

class _WebEditorState extends State<WebEditor> {
    late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            // setJsItem();
          },
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://mycompany.ourshop.shop/design-flutter?token=${locator<Preferences>().preferences['token']}')
      );
  }

  void setJsItem(){
    final user = context.read<UsersBloc>().state.loggedUser.toJson();
    user['token'] = locator<Preferences>().preferences['token'];
    final userjson = jsonEncode(user);
    controller.runJavaScript('''
        sessionStorage.setItem('decodedToken', '$userjson');
        sessionStorage.setItem('tokenUser', '{"success":true,"message":"Login successful","data":{"token":"${locator<Preferences>().preferences['token']}","refreshToken":"${locator<Preferences>().preferences['refreshToken']}"}}');
        console.log('Session storage set!');
    ''');
  }

  void getJsItem(){
    controller.runJavaScript('''
      const decodedToken = sessionStorage.getItem('decodedToken');
      const tokenUser = sessionStorage.getItem('tokenUser');
      console.log('Decoded Token:', decodedToken);
      console.log('Token User:', tokenUser);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            Positioned(
              top: 5,
              left: -7,
              child: IconButton(
                onPressed: () {
                  context.pop();
                }, 
                icon: const Icon(Icons.arrow_back)
              ),
            ),
          ]
        )
      ),
    );
  }
}