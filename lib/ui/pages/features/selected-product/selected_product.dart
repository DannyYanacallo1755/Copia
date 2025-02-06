import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../../models/available_currency.dart';
import '../../pages.dart';

class SelectedProductPage extends StatefulWidget {
  const SelectedProductPage({super.key, required this.product});

  final FilteredProduct product;

  @override
  State<SelectedProductPage> createState() => _SelectedProductPageState();
}

class _SelectedProductPageState extends State<SelectedProductPage> {
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
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    const Widget spacer = SizedBox(
      width: 10.0,
    );

    const Widget spacerContact = SizedBox(
      width: 5.0,
    );

    return !_loading
        ? BlocListener<ProductsBloc, ProductsState>(
            listenWhen: (previous, current) =>
                current.cartProducts.length > previous.cartProducts.length,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                content: Text(translations.product_added_to_cart),
                actions: [
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .hideCurrentMaterialBanner(),
                    child: Text(
                      translations.close,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  )
                ],
              ));
              Future.delayed(const Duration(milliseconds: 1500), () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              });
            },
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      style: theme.iconButtonTheme.style?.copyWith(
                        shadowColor:
                            WidgetStatePropertyAll(Colors.grey.shade300),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop()),
                  title: Text(
                    translations.detail_product,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _Image(
                        size: size,
                        product: widget.product,
                        theme: theme,
                        translations: translations,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                widget.product.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xff5d5f61),
                                  fontWeight: FontWeight.w700,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: BlocBuilder<ProductsBloc, ProductsState>(
                              builder: (context, state) {
                                return Icon(
                                  state.favoriteProducts
                                          .contains(widget.product)
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: state.favoriteProducts
                                          .contains(widget.product)
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                );
                              },
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      if (widget.product.productReviewInfo?.ratingAvg != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 10.0),
                              child: Text(
                                widget.product.productReviewInfo!.ratingAvg
                                    .toStringAsFixed(1),
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(color: Colors.black),
                              ),
                            ),
                            RaitingBarWidget(product: widget.product),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        widget.product.unitPrice != null
                                            ? currency?.symbol != '\$'
                                                ? ' ${currency?.symbol} ${NumberFormat('#,###').format(widget.product.unitPrice! * (currency?.dollarPrice ?? 1.0))}'
                                                : '${currency?.symbol} ${NumberFormat('#,###.00').format(widget.product.unitPrice! * (currency?.dollarPrice ?? 1.0))}'
                                            : (widget.product.fboPriceStart !=
                                                        null &&
                                                    widget.product
                                                            .fboPriceEnd !=
                                                        null
                                                ? currency?.symbol != '\$'
                                                    ? '${currency?.symbol}${NumberFormat('#,###').format(widget.product.fboPriceStart! * (currency?.dollarPrice ?? 1.0))}-${currency?.symbol}${NumberFormat('#,###').format(widget.product.fboPriceEnd! * (currency?.dollarPrice ?? 1.0))}'
                                                    : '${currency?.symbol}${NumberFormat('#,###.00').format(widget.product.fboPriceStart! * (currency?.dollarPrice ?? 1.0))}-${currency?.symbol}${NumberFormat('#,###.00').format(widget.product.fboPriceEnd! * (currency?.dollarPrice ?? 1.0))}'
                                                : '0'),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                color: const Color(0xff5d5f61),
                                                fontWeight: FontWeight.w600),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Section(
                        title: translations.specifications,
                        content: widget.product.name,
                        theme: theme,
                        translations: translations,
                        type: SectionType.text,
                      ),
                      Section(
                        title: translations.details,
                        content: widget.product.name,
                        theme: theme,
                        translations: translations,
                        type: SectionType.text,
                      ),
                      Section(
                        title: translations.videos,
                        content: '',
                        theme: theme,
                        translations: translations,
                        type: SectionType.videos,
                        product: widget.product,
                      ),
                      Section(
                        title: translations.comments,
                        content: '',
                        theme: theme,
                        translations: translations,
                        product: widget.product,
                        type: SectionType.custom,
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: CustomBottomBar(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        if (widget.product.unitPrice == null) {
                          return SizedBox(
                            width: size.width * 0.9,
                            child: ElevatedButton(
                              style: theme.elevatedButtonTheme.style?.copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                    if (states
                                        .contains(MaterialState.disabled)) {
                                      return Colors.grey.shade400;
                                    }
                                    return Colors.green;
                                  },
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14.0),
                                ),
                              ),
                              onPressed: () =>
                                  ContactSellerDialog(product: widget.product)
                                      .showAlertDialog(
                                          context, translations, theme),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.support_agent_outlined,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    translations.contact_seller,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style:
                                    theme.outlinedButtonTheme.style?.copyWith(
                                  padding: const WidgetStatePropertyAll<
                                      EdgeInsetsGeometry>(
                                    EdgeInsets.zero,
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  side: MaterialStateProperty.all(BorderSide(
                                    color: AppTheme.palette[1000]!,
                                    width: 1.5,
                                  )),
                                ),
                                onPressed: () => context
                                    .read<ProductsBloc>()
                                    .add(AddCartProductEvent(
                                        product: widget.product)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppTheme.palette[1000],
                                      size: 18.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        translations.add_to_cart,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: AppTheme.palette[1000],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style:
                                    theme.elevatedButtonTheme.style?.copyWith(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.grey.shade400;
                                      }
                                      return Colors.green;
                                    },
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                  ),
                                ),
                                onPressed: () =>
                                    ContactSellerDialog(product: widget.product)
                                        .showAlertDialog(
                                            context, translations, theme),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.support_agent_outlined,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        translations.contact_seller,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  context.push('/cart');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: SizedBox(
                                    width: 20,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: AppTheme.palette[1000],
                                          size: 20.0,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            context
                                                .watch<ProductsBloc>()
                                                .state
                                                .cartProducts
                                                .length
                                                .toString(),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                    color:
                                                        AppTheme.palette[1000],
                                                    fontSize: 12.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )),
          )
        : const Center(child: CircularProgressIndicator.adaptive());
  }
}

class _Image extends StatelessWidget {
  _Image({
    required this.size,
    required this.product,
    required this.theme,
    required this.translations,
  });

  final Size size;
  final FilteredProduct product;
  final ThemeData theme;
  final AppLocalizations translations;

  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (product.productPhotos.isEmpty) {
      Center(
        child: Icon(
          Icons.image_not_supported,
          size: 100.0,
          color: Colors.grey.shade500,
        ),
      );
    }

    return SizedBox(
        height: size.height * 0.4,
        width: size.width,
        child: Column(
          children: [
            Expanded(
                child: product.productPhotos.isNotEmpty
                    ? CarouselSlider(
                        carouselController: _controller,
                        options: CarouselOptions(
                          height: size.height * 2,
                          viewportFraction: 0.7,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            _currentPage.value = index;
                          },
                        ),
                        items: product.productPhotos.map((photo) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: ProductImage(
                                product: product,
                                flagUrl: '',
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 100.0,
                            color: Colors.grey.shade500,
                          ),
                          Text(translations.no_image,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: Colors.grey.shade500)),
                        ],
                      )),
            if (product.productPhotos.isNotEmpty)
              Stack(children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        product.productPhotos.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: ValueListenableBuilder(
                          valueListenable: _currentPage,
                          builder: (BuildContext context, value, child) {
                            return Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: value == entry.key
                                      ? AppTheme.palette[1000]
                                      : AppTheme.palette[700]),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(right: 10.0),
                      height: 30.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                        color: AppTheme.palette[800],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Center(
                          child: ValueListenableBuilder(
                        valueListenable: _currentPage,
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            '${value + 1}/${product.productPhotos.length}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(fontSize: 10.0, color: Colors.white),
                          );
                        },
                      )),
                    )),
              ])
            else
              const SizedBox.shrink()
          ],
        ));
  }
}
