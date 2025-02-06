import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../../models/available_currency.dart';
import '../../pages.dart';

class Cart extends StatefulWidget {
  const Cart({super.key, this.canBack = false});

  final bool canBack;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  Currency? currency;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  void _loadCurrency() async {
    currency = await getCurrency();
    setState(() {
      _loading = false;
    });
  }

  Future<Currency?> getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency');
    if (currencies == null || currencies.isEmpty) {
      return null;
    }
    return Currency.fromJson(jsonDecode(currencies));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: widget.canBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : TextButton(
                onPressed: () =>
                    context.read<ProductsBloc>().selectedCartProductsCount == 0
                        ? context.read<ProductsBloc>().selectAllCartProducts()
                        : context
                            .read<ProductsBloc>()
                            .deselectAllCartProducts(),
                child: Text(
                  '${context.watch<ProductsBloc>().selectedCartProductsCount == 0 ? translations.select_all : translations.deselect_all} ${context.watch<ProductsBloc>().selectedCartProductsCount}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppTheme.palette[1000]!),
                )),
        leadingWidth: widget.canBack ? null : 150,
        title: Text(
          translations.cart,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: AppTheme.palette[1000]),
        ),
        actions: [
          TextButton(
            child: Text(
              translations.clear_all,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: AppTheme.palette[1000]),
            ),
            onPressed: () {
              context.read<ProductsBloc>().add(const ClearCart());
            },
          ),
        ],
      ),
      body: !_loading
          ? Column(
              children: [
                if (widget.canBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                        onPressed: () => context
                                    .read<ProductsBloc>()
                                    .selectedCartProductsCount ==
                                0
                            ? context
                                .read<ProductsBloc>()
                                .selectAllCartProducts()
                            : context
                                .read<ProductsBloc>()
                                .deselectAllCartProducts(),
                        child: Text(
                          '${context.watch<ProductsBloc>().selectedCartProductsCount == 0 ? translations.select_all : translations.deselect_all} ${context.watch<ProductsBloc>().selectedCartProductsCount}',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: Colors.white),
                        )),
                  )
                else
                  const SizedBox.shrink(),
                Expanded(
                  child: SizedBox(
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        if (state.cartProducts.isEmpty) {
                          return Center(
                            child: Text(
                              translations.cart_empty,
                              style: theme.textTheme.titleMedium,
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.cartProducts.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              key: Key(state.cartProducts[index].id),
                              background: const ColoredBox(
                                color: Colors.red,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    )),
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) {
                                return DeleteProductDialog(
                                        productName:
                                            state.cartProducts[index].name)
                                    .showAlertDialog(
                                        context, translations, theme)
                                    .then((value) {
                                  if (value != null && value) {
                                    context.read<ProductsBloc>().add(
                                        RemoveCartProductEvent(
                                            product:
                                                state.cartProducts[index]));
                                    return Future.value(value);
                                  }
                                  return Future.value(false);
                                });
                              },
                              onDismissed: (direction) {
                                context.read<ProductsBloc>().add(
                                    RemoveCartProductEvent(
                                        product: state.cartProducts[index]));
                              },
                              child: CartCard(
                                showCheckBox: true,
                                product: state.cartProducts[index],
                                currency: currency!,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                        onPressed: context
                                    .read<ProductsBloc>()
                                    .state
                                    .cartProducts
                                    .isEmpty ||
                                context
                                        .read<ProductsBloc>()
                                        .selectedCartProductsPrice ==
                                    0.00
                            ? null
                            : () => context.push('/checkout'),
                        child: Text(
                          '${translations.checkout} ${currency?.symbol != '\$' ? '${currency?.symbol} ${NumberFormat('#,###').format(context.watch<ProductsBloc>().selectedCartProductsPrice * currency!.dollarPrice)}' : '\$${NumberFormat('#,###.00').format(context.watch<ProductsBloc>().selectedCartProductsPrice * currency!.dollarPrice)}'}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
