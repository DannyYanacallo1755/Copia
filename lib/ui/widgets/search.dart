import 'dart:convert';
import 'dart:developer';

import 'package:ourshop_ecommerce/models/models.dart';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

import '../../models/available_currency.dart';

class Search extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '', // Limpiar el query
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    query = query.trim(); // Limpiar los espacios alrededor del query
    return SearchResults(
      query: query,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SearchSuggestions();
  }
}

//Suggestions
class SearchSuggestions extends StatefulWidget {
  const SearchSuggestions({
    super.key,
  });

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  late ScrollController _scrollController;
  Currency? currency;
  @override
  void initState() {
    super.initState();
    _loadCurrency();

    _scrollController = ScrollController()..addListener(listener);
  }

  void _loadCurrency() async {
    currency = await getCurrency();
    setState(() {
      fetchFilteredProducts();
    });
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

  getCurrency() async {
    late SharedPreferences preferences;
    preferences = await SharedPreferences.getInstance();
    var currencies = preferences.getString('currency')!;
    Currency currencys = Currency.fromJson(jsonDecode(currencies));
    return currencys;
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
    context.read<ProductsBloc>().add(AddFilteredProductsSuggestionsEvent(
          page: context.read<ProductsBloc>().state.suggestionsCurrentPage + 1,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final TextStyle? style =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.black);

    return SizedBox(
        height: size.height,
        width: size.width,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          buildWhen: (previous, current) =>
              previous.filteredBuildResults != current.filteredBuildResults ||
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

            return GridView.builder(
              controller: _scrollController,
              itemCount: state.hasMore
                  ? state.filteredProductsSuggestions.length + 1
                  : state.filteredProductsSuggestions.length,
              itemBuilder: (context, index) {
                if (index == state.filteredProductsSuggestions.length) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (state.filteredProductsSuggestions.isEmpty) {
                  return Center(
                      child: Text(
                    translations.no_results_found,
                    style: style,
                  ));
                }
                final FilteredProduct product =
                    state.filteredProductsSuggestions[index];
                return ProductCard(
                    height: size.height,
                    width: size.width,
                    product: product,
                    theme: theme,
                    translations: translations,
                    currency: currency!);
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6),
            );
          },
        ));
  }
}

class SearchResults extends StatefulWidget {
  const SearchResults({super.key, required this.query});

  final String query;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  late ScrollController _scrollController;
  Currency? currency;

  @override
  void initState() {
    super.initState();
    _loadCurrency();

    _scrollController = ScrollController()..addListener(listener);
  }

  void _loadCurrency() async {
    currency = await getCurrency();
    setState(() {
      fetchFilteredProducts();
    });
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
    context.read<ProductsBloc>().add(AddFilteredBuildResultsEvent(
          query: widget.query,
          page: context.read<ProductsBloc>().state.resultsCurrentPage + 1,
        ));
  }

  @override
  void deactivate() {
    log('deactivate search results');
    context.read<ProductsBloc>().add(const ResetStatesEvent());
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final TextStyle? style =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.black);

    return SizedBox(
        height: size.height,
        width: size.width,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          buildWhen: (previous, current) =>
              previous.filteredBuildResults != current.filteredBuildResults ||
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

            if (state.filteredBuildResults.isEmpty) {
              return Center(
                  child: Text(
                translations.no_results_found,
                style: style,
              ));
            }

            return GridView.builder(
              controller: _scrollController,
              itemCount: state.hasMore
                  ? state.filteredBuildResults.length + 1
                  : state.filteredBuildResults.length,
              itemBuilder: (context, index) {
                if (index == state.filteredBuildResults.length) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (state.filteredBuildResults.isEmpty) {
                  return Center(
                      child: Text(
                    translations.no_results_found,
                    style: style,
                  ));
                }

                final FilteredProduct product =
                    state.filteredBuildResults[index];
                return ProductCard(
                  height: size.height,
                  width: size.width,
                  product: product,
                  theme: theme,
                  translations: translations,
                  currency: currency!,
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6),
            );
          },
        ));
  }
}
