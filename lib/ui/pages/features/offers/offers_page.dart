import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../../models/available_currency.dart';
import '../../pages.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  late ScrollController _scrollController;
  Currency? currency;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(listener);
    _loadCurrency();
    fetchOfferProducts();
  }

  void _loadCurrency() async {
    currency = await getCurrency();
  }

  @override
  void dispose() {
    _scrollController.removeListener(listener);
    _scrollController.dispose();
    super.dispose();
  }

  void listener() {
    final double threshold = _scrollController.position.maxScrollExtent * 0.9;
    if (_scrollController.position.pixels >= threshold &&
        context.read<ProductsBloc>().state.hasMore &&
        context.read<ProductsBloc>().state.productsStates !=
            ProductsStates.loadingMore) {
      fetchOfferProducts();
    }
  }

  void fetchOfferProducts() async {
    context.read<ProductsBloc>().add(AddOfferProductEvent(
          page: context.read<ProductsBloc>().state.offerProductsCurrentPage + 1,
        ));
  }

  getCurrency() async {
    late SharedPreferences preferences;
    preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency')!;
    Currency currencys = Currency.fromJson(jsonDecode(currencies));
    return currencys;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;
    final TextStyle? style =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.black);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: size.height,
        width: size.width,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          buildWhen: (previous, current) =>
              previous.offerProducts != current.offerProducts ||
              previous.productsStates != current.productsStates,
          builder: (context, state) {
            if (state.productsStates == ProductsStates.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state.productsStates == ProductsStates.error) {
              return Center(
                  child: Text(
                translations.error,
                style: style,
              ));
            }

            if (state.offerProducts.isEmpty) {
              return Center(
                  child: Text(
                translations.no_results_found,
                style: style,
              ));
            }

            return GridView.builder(
              controller: _scrollController,
              itemCount: state.hasMore
                  ? state.offerProducts.length + 1
                  : state.offerProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.53,
              ),
              itemBuilder: (context, index) {
                if (index == state.offerProducts.length) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (state.offerProducts.isEmpty) {
                  return Center(
                    child: Text(
                      translations.no_results_found,
                      style: style,
                    ),
                  );
                }

                final FilteredOfferProduct product = state.offerProducts[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8.0),
                              ),
                              child: ProductImage(
                                product: product.product!,
                                flagUrl: product.flagUrl!,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    '-${product.getDiscountType() == DiscountType.FIXED ? currency?.symbol != '\$' ? '${currency?.symbol}${NumberFormat('#,###').format(((product.discountValue ?? 0.0) * (currency?.dollarPrice ?? 1.0)))}' // Usar '0.0' si es nulo
                                        : '\$${NumberFormat('#,###.00').format(((product.discountValue ?? 0.0) * (currency?.dollarPrice ?? 1.0)))}' : '${product.discountValue ?? 0}%'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Helpers.truncateText(product.product!.name, 18),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            if (product.product!.productReviewInfo?.ratingAvg !=
                                null)
                              Row(
                                children: [
                                  Text(
                                    product
                                        .product!.productReviewInfo!.ratingAvg
                                        .toStringAsFixed(1),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  RaitingBarWidget(product: product.product!),
                                ],
                              ),
                            const SizedBox(height: 6.0),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (product.product!.unitPrice != null)
                                    Text(
                                      product.product?.unitPrice != null
                                          ? currency?.symbol != '\$'
                                              ? '${currency?.symbol}${NumberFormat('#,###').format((product.product!.unitPrice! * (currency?.dollarPrice ?? 1.0)))}'
                                              : '${currency?.symbol}${NumberFormat('#,###.00').format((product.product!.unitPrice! * (currency?.dollarPrice ?? 1.0)))}'
                                          : '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    product.newprice != null
                                        ? currency?.symbol != '\$'
                                            ? '${currency?.symbol}${NumberFormat('#,###').format((product.newprice! * (currency?.dollarPrice ?? 1.0)))}'
                                            : '${currency?.symbol}${NumberFormat('#,###.00').format((product.newprice! * (currency?.dollarPrice ?? 1.0)))}'
                                        : '',
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => {
                                  context.read<ProductsBloc>().add(
                                      AddCartProductEvent(
                                          product: product.product!)),
                                  SuccessToast(
                                    title:
                                        AppLocalizations.of(context)!.suceess,
                                    description: AppLocalizations.of(context)!
                                        .product_added_to_cart,
                                    style: ToastificationStyle.flatColored,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green.shade500,
                                    icon: const Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.white,
                                    ),
                                  ).showToast(context)
                                },
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.palette[1000],
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
