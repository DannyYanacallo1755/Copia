import 'dart:convert';

import '../../../../models/available_currency.dart';
import '../../pages.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  final Map<String, ScrollController> _scrollControllers = {};
  Currency? currency;

  @override
  void initState() {
    _loadCurrency();
    context.read<ProductsBloc>().add(const AddCategoriesEvent());
    super.initState();
  }

  @override
  void dispose() {
    _scrollControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _loadCurrency() async {
    currency = await getCurrency();
  }

  Future<Currency?> getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency');
    if (currencies == null || currencies.isEmpty) {
      return null;
    }
    return Currency.fromJson(jsonDecode(currencies));
  }

  ScrollController _getOrCreateScrollController(String categoryId) {
    if (!_scrollControllers.containsKey(categoryId)) {
      _scrollControllers[categoryId] = ScrollController()
        ..addListener(() {
          final double threshold =
              _scrollControllers[categoryId]!.position.maxScrollExtent * 0.05;
          if (_scrollControllers[categoryId]!.position.pixels >= threshold &&
              context.read<ProductsBloc>().state.hasMore &&
              context.read<ProductsBloc>().state.productsStates !=
                  ProductsStates.loadingMore) {
            fetchFilteredProducts();
          }
        });
    }
    return _scrollControllers[categoryId]!;
  }

  void fetchFilteredProducts() {
    context.read<ProductsBloc>().add(AddFilteredProductsEvent(
          page: context.read<ProductsBloc>().state.currentPage + 1,
          mode: FilteredResponseMode.generalCategoryProducts,
          categoryId: context.read<ProductsBloc>().state.selectedParentCategory,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state.selectedSubCategory.id.isNotEmpty) {
          context.go(
            '/sub-category/${state.selectedSubCategory.id}',
          );
        }
      },
      listenWhen: (previous, current) {
        if (previous.selectedSubCategory.id != current.selectedSubCategory.id)
          return true;
        return false;
      },
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.productsStates != current.productsStates ||
          previous.selectedParentCategory != current.selectedParentCategory ||
          previous.parentCategoryLoaded != current.parentCategoryLoaded,
      builder: (context, state) {
        if (!state.parentCategoryLoaded) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.productsStates == ProductsStates.error) {
          return Center(
              child: Text(
            'Something went wrong!',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppTheme.palette[1000]),
          ));
        }

        return DefaultTabController(
          initialIndex: state.selectedParentCategory.isEmpty
              ? 0
              : state.categories.indexWhere(
                  (element) => element.id == state.selectedParentCategory),
          length: state.categories.length,
          child: SafeArea(
            top: true,
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size(size.width, size.height * 0.12),
                  child: IgnorePointer(
                    ignoring:
                        state.productsStates == ProductsStates.loadingMore ||
                            state.productsStates == ProductsStates.loading,
                    child: AppBar(
                      backgroundColor: AppTheme.palette[900],
                      leadingWidth: size.width * 0.25,
                      automaticallyImplyLeading: false,
                      leading: FittedBox(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () => showSearch(
                                    context: context, delegate: Search()),
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                )),
                            Text(
                              translations.search,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      centerTitle: true,
                      title: Image.asset(
                        'assets/logos/logo_ourshop_1.png',
                        height: 150,
                        width: 150,
                      ),
                      bottom: TabBar(
                        unselectedLabelStyle: theme
                            .tabBarTheme.unselectedLabelStyle
                            ?.copyWith(color: Colors.white),
                        labelStyle: theme.tabBarTheme.unselectedLabelStyle
                            ?.copyWith(color: Colors.white),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        onTap: (index) => context
                            .read<ProductsBloc>()
                            .add(AddSelectedParentCategoryEvent(
                              selectedParentCategory:
                                  state.categories[index].id,
                            )),
                        tabs: state.categories
                            .map((
                              category,
                            ) =>
                                Tab(
                                  text: Helpers.truncateText(category.name, 25),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                body: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: TabBarView(
                    children: state.categories.map((category) {
                      switch (category.id) {
                        case "all":
                          return const AllProducts();
                        default:
                          return SizedBox(
                            height: size.height,
                            width: size.width,
                            child: Column(
                              key: PageStorageKey<String>(category.id),
                              children: [
                                SizedBox(
                                  height: size.height * 0.08,
                                  width: size.width,
                                  child: SubCategoryList(
                                    category: category,
                                    size: size,
                                    translations: translations,
                                    theme: theme,
                                    onTap: (selectedSubCategory) {
                                      context.read<ProductsBloc>().add(
                                          AddSelectedSubCategoryEvent(
                                              selectedSubCategoryId:
                                                  selectedSubCategory.id));
                                      // context.go('/sub-category/${selectedSubCategory.id}',);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: state.productsStates ==
                                          ProductsStates.loading
                                      ? const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        )
                                      : state.filteredProducts.isEmpty
                                          ? Center(
                                              child: Text(
                                              'No Products Found',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      color:
                                                          Colors.grey.shade500),
                                            ))
                                          : GridView.builder(
                                              controller:
                                                  _getOrCreateScrollController(
                                                      category.id),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 10,
                                                      mainAxisSpacing: 10,
                                                      childAspectRatio: 0.6),
                                              itemCount: state.hasMore
                                                  ? state.filteredProducts
                                                          .length +
                                                      1
                                                  : state
                                                      .filteredProducts.length,
                                              itemBuilder: (context, index) {
                                                if (index ==
                                                    state.filteredProducts
                                                        .length) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive());
                                                }
                                                final FilteredProduct product =
                                                    state.filteredProducts[
                                                        index];
                                                return ProductCard(
                                                    height: size.height,
                                                    width: size.width,
                                                    product: product,
                                                    theme: theme,
                                                    translations: translations,
                                                    currency: currency!);
                                              },
                                            ),
                                )
                              ],
                            ),
                          );
                      }
                    }).toList(),
                  ),
                )),
          ),
        );
      },
    );
  }
}

class AllProducts extends StatefulWidget {
  const AllProducts({
    super.key,
  });

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  late ScrollController _scrollController;
  Currency? currency;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _scrollController = ScrollController()..addListener(listener);
    fetchFilteredProducts();
  }

  void _loadCurrency() async {
    currency = await getCurrency();
  }

  getCurrency() async {
    late SharedPreferences preferences;
    preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency')!;
    Currency currencys = Currency.fromJson(jsonDecode(currencies));
    return currencys;
  }

  @override
  void dispose() {
    _scrollController.removeListener(listener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    context.read<ProductsBloc>().add(const ResetStatesEvent());
    super.deactivate();
  }

  void listener() {
    final double threshold = _scrollController.position.maxScrollExtent * 0.1;
    if (_scrollController.position.pixels >= threshold &&
        context.read<ProductsBloc>().state.hasMore &&
        context.read<ProductsBloc>().state.productsStates !=
            ProductsStates.loadingMore) {
      fetchFilteredProducts();
    }
  }

  void fetchFilteredProducts() async {
    context.read<ProductsBloc>().add(AddFilteredProductsEvent(
          page: context.read<ProductsBloc>().state.currentPage + 1,
          mode: FilteredResponseMode.all,
          categoryId: '',
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final TextStyle style =
        theme.textTheme.bodyMedium!.copyWith(color: Colors.black);
    return SizedBox(
        height: size.height,
        width: size.width,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          buildWhen: (previous, current) =>
              previous.filteredProducts != current.filteredProducts,
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

            return GridView.builder(
              controller: _scrollController,
              itemCount: state.hasMore
                  ? state.filteredProducts.length + 1
                  : state.filteredProducts.length,
              itemBuilder: (context, index) {
                if (index == state.filteredProducts.length) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (state.filteredProducts.isEmpty) {
                  return Center(
                      child: Text(
                    translations.no_results_found,
                    style: style,
                  ));
                }
                final FilteredProduct product = state.filteredProducts[index];
                return ProductCard(
                  height: size.height,
                  width: size.width,
                  product: product,
                  theme: theme,
                  translations: translations,
                  currency: currency!,
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6),
            );
          },
        ));
  }
}
