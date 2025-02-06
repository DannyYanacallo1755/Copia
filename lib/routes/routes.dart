import 'dart:developer';

import '../ui/pages/pages.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get globalContext => _navigatorKey.currentContext;

  static String? _lastVisitedPage() {
    final String? lastVisitedPage =
        locator<Preferences>().preferences['last_visited_page'];
    log('lastVisitedPage: $lastVisitedPage');
    switch (lastVisitedPage) {
      case 'choose_language_page':
        return '/choose-language';
      case 'sign_in_page':
        return '/';
      default:
        return '/splash';
    }
  }

  static final String _initialPage = _lastVisitedPage() ?? '/splash';
  static GoRouter router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: _initialPage,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/choose-language',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ChooseLanguagePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/selected-product',
        builder: (context, state) {
          final FilteredProduct product = state.extra as FilteredProduct;
          return SelectedProductPage(product: product);
        },
      ),
      GoRoute(
        path: '/sub-category/:id',
        builder: (context, state) {
          final String categoryId = state.pathParameters['id']!;
          return SubCategoryPage(
            key: ValueKey(categoryId),
            categoryId: categoryId,
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const Cart(
          canBack: true,
        ),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
          path: '/admin',
          builder: (context, state) => AdminPage(),
          routes: [
            GoRoute(
                path: 'option/my-company',
                builder: (context, state) {
                  final AdminOptions option = state.extra as AdminOptions;
                  return AdminOptionPage(
                    option: option,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'WebEditor',
                    builder: (context, state) {
                      return const WebEditor();
                    },
                  )
                ]),
            GoRoute(
                path: 'option/orders',
                builder: (context, state) {
                  final AdminOptions option = state.extra as AdminOptions;
                  return AdminOptionPage(
                    option: option,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final FilteredOrders order =
                          state.extra as FilteredOrders;
                      return OrderDetailPage(order: order);
                    },
                  )
                ]),
            GoRoute(
                path: 'option/products',
                builder: (context, state) {
                  final AdminOptions option = state.extra as AdminOptions;
                  return AdminOptionPage(
                    option: option,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) {
                      return const NewAdminProduct();
                    },
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final FilteredProduct product =
                          state.extra as FilteredProduct;
                      return AdminProductDetail(
                        product: product,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'countries-groups',
                    builder: (context, state) {
                      return const CountryGroupPage();
                    },
                  ),
                  GoRoute(
                    path: 'shipping-rates',
                    builder: (context, state) {
                      return ShippingRatePage();
                    },
                  ),
                  GoRoute(
                    path: 'offers',
                    builder: (context, state) => const AdminOffersPage(),
                  ),
                ]),
            GoRoute(
              path: 'option/communication',
              builder: (context, state) => const AdminCommunicationPage(),
            )
          ]),
    ],
  );
}
