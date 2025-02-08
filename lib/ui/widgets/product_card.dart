import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:ourshop_ecommerce/models/available_currency.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class ProductCard extends StatelessWidget {
  const ProductCard(
      {super.key,
      required this.height,
      required this.width,
      required this.product,
      required this.theme,
      required this.translations,
      required this.currency
      });

  final double height;
  final double width;
  final FilteredProduct product;
  final ThemeData theme;
  final AppLocalizations translations;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/selected-product', extra: product),
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    topRight: Radius.circular(5.0)),
                child: ProductImage(product: product, flagUrl: ''),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Column(
                children: [
                  Text(
                    Helpers.truncateText(product.name, 18),
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5.0),
                  if (product.productReviewInfo?.ratingAvg != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            product.productReviewInfo!.ratingAvg
                                .toStringAsFixed(1),
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: Colors.black),
                          ),
                        ),
                        RaitingBarWidget(product: product),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  if (product.productReviewInfo?.summary != null &&
                      product.productReviewInfo!.summary!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          translations.product_ratings(
                              product.productReviewInfo!.reviewCount ?? 0.0),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 2.0),
                  const SendAnimatedWidget(),
                  Row(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          product.unitPrice != null
                              ? currency.symbol != '\$'
                                  ? '${currency.symbol}${NumberFormat('#,###').format(product.unitPrice! * currency.dollarPrice)}'
                                  : '${currency.symbol}${NumberFormat('#,###.00').format(product.unitPrice! * currency.dollarPrice)}'
                              : (product.fboPriceStart != null &&
                                      product.fboPriceEnd != null
                                  ? currency.symbol != '\$'
                                      ? '${currency.symbol}${NumberFormat('#,###').format(product.fboPriceStart! * currency.dollarPrice)}-${currency.symbol}${NumberFormat('#,###').format(product.fboPriceEnd! * currency.dollarPrice)}'
                                      : '${currency.symbol}${NumberFormat('#,###.00').format(product.fboPriceStart! * currency.dollarPrice)}-${currency.symbol}${NumberFormat('#,###.00').format(product.fboPriceEnd! * currency.dollarPrice)}'
                                  : '0'),
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5),
                        ),
                      ),
                      const Spacer(),
                      if (product.unitPrice != null)
                        GestureDetector(
                          onTap: () => {
                            context
                                .read<ProductsBloc>()
                                .add(AddCartProductEvent(product: product)),
                            SuccessToast(
                              title: AppLocalizations.of(context)!.suceess,
                              description: AppLocalizations.of(context)!
                                  .product_added_to_cart,
                              style: ToastificationStyle.flatColored,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green.shade500,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ).showToast(context)
                          },
                          child: CircleAvatar(
                            maxRadius: 18,
                            backgroundColor: AppTheme.palette[1000],
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        )
                    ],
                  ),
                  Text(
                    '(min 1)',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendAnimatedWidget extends StatefulWidget {
  const SendAnimatedWidget({
    super.key,
  });

  @override
  State<SendAnimatedWidget> createState() => _SendAnimatedWidgetState();
}

class _SendAnimatedWidgetState extends State<SendAnimatedWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_controller]),
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            translations.send,
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.pink),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.delivery_dining,
              color: Colors.pink,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  ProductImage({
    super.key,
    required this.product,
    required this.flagUrl,
  });

  final FilteredProduct product;
  late String flagUrl = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.black);
    final AppLocalizations translations = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          CachedNetworkImage(
            key: ValueKey<String>(product.id),
            cacheKey: product.id,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorWidget: (context, url, error) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error),
                  Text(
                    translations.error_laoding_image,
                    style: style,
                  ),
                ],
              );
            },
            imageBuilder: (context, imageProvider) {
              return Image(image: imageProvider, fit: BoxFit.cover);
            },
            errorListener: (value) {
              log('value: $value');
            },
            placeholderFadeInDuration: const Duration(milliseconds: 500),
            fadeInDuration: const Duration(milliseconds: 500),
            fadeOutDuration: const Duration(milliseconds: 500),
            fadeInCurve: Curves.easeIn,
            fadeOutCurve: Curves.easeOut,
            progressIndicatorBuilder: (context, url, progress) {
              return Center(
                child: CircularProgressIndicator.adaptive(
                  value: progress.progress,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.palette[1000]!),
                ),
              );
            },
            imageUrl: product.mainPhotoUrl != null
                ? '${dotenv.env['PRODUCT_URL']}${product.mainPhotoUrl}'
                : product.productPhotos.isNotEmpty
                    ? '${dotenv.env['PRODUCT_URL']}${product.productPhotos.first.photo?.url}'
                    : 'https://via.placeholder.com/150',
          ),
          if (product.flagUrl != null)
            Positioned(
              top: 4,
              right: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${dotenv.env['FLAG_URL']}${product.flagUrl}',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ),
          if (flagUrl != '')
            Positioned(
              top: 4,
              right: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${dotenv.env['FLAG_URL']}$flagUrl',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CartCard extends StatelessWidget {
  const CartCard(
      {super.key,
      required this.product,
      this.height,
      this.width,
      this.showCheckBox = false,
      this.showIncreaseDecrease = false,
      this.showFavoriteButton = false,
      required this.currency});

  final FilteredProduct product;
  final double? height;
  final double? width;
  final bool? showCheckBox;
  final bool? showIncreaseDecrease;
  final bool? showFavoriteButton;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Container(
      height: height ?? MediaQuery.of(context).size.height * 0.15,
      width: width ?? MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade500,
            width: 1.0,
          ),
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showCheckBox!)
            Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(
                  value: product.selected,
                  onChanged: (value) => context
                      .read<ProductsBloc>()
                      .add(SelectOrDeselectCartProductEvent(product: product))),
            )
          else
            const SizedBox.shrink(),
          SizedBox(
            width: size.width * 0.3,
            height: size.height,
            child: ProductImage(
              product: product,
              flagUrl: '',
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (_, state) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            Helpers.truncateText(product.name, 18),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            product.unitPrice != null
                                ? currency.symbol != '\$'
                                    ? '${currency.symbol} ${NumberFormat('#,###').format((product.unitPrice ?? 0) * (product.quantity ?? 0) * currency.dollarPrice)}'
                                    : '\$${NumberFormat('#,###.00').format((product.unitPrice ?? 0) * (product.quantity ?? 0) * currency.dollarPrice)}'
                                : currency.symbol != '\$'
                                    ? '${currency.symbol} ${NumberFormat('#,###').format((product.fboPriceEnd ?? 0) * (product.quantity ?? 0) * currency.dollarPrice)}'
                                    : '\$${NumberFormat('#,###.00').format((product.fboPriceEnd ?? 0) * (product.quantity ?? 0) * currency.dollarPrice)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // GestureDetector(
                          //   onTap: () {},
                          //   child: Icon(state.favoriteProducts.contains(product) ? Icons.favorite : Icons.favorite_border_outlined, color: state.favoriteProducts.contains(product) ? Colors.red : Colors.grey ,)
                          // ),
                          // const Spacer(),
                          //TODO add increase decrease
                          IncreaseDecrease(theme: theme, product: product),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class IncreaseDecrease extends StatelessWidget {
  const IncreaseDecrease(
      {super.key, required this.theme, required this.product});

  final ThemeData theme;
  final FilteredProduct product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context
              .read<ProductsBloc>()
              .add(RemoveCartProductEvent(product: product)),
          icon: Icon(
            Icons.remove_circle_outline,
            color: AppTheme.palette[900],
          ),
        ),
        Text(
          product.quantity.toString(),
          style: theme.textTheme.labelMedium
              ?.copyWith(color: AppTheme.palette[900]),
        ),
        IconButton(
          onPressed: () => context
              .read<ProductsBloc>()
              .add(AddCartProductEvent(product: product)),
          icon: Icon(Icons.add_circle_outline, color: AppTheme.palette[900]),
        ),
      ],
    );
  }
}
