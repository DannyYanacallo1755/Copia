import 'package:ourshop_ecommerce/ui/pages/pages.dart';
import 'dart:convert';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  late ScrollController _scrollController;
  String language = 'es';
  ValueNotifier<List<Category>> categories = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    fetchAdminProducts();
    _loadCategories();

    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void fetchAdminProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final languageId = prefs.get('language');
    language = (languageId == '1') ? 'en' : 'es';

    context.read<ProductsBloc>().add(AddAdminProductsEvent(
          companyId: context.read<UsersBloc>().state.loggedUser.companyId,
          page: 1,
        ));
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories =
          await locator<CategoryService>().getParentCategories();
      categories.value = loadedCategories;
    } catch (e) {
      debugPrint('Error al cargar categorías: $e');
    }
  }

  void _scrollListener() {
    final productsBloc = context.read<ProductsBloc>();
    final state = productsBloc.state;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        state.productsStates != ProductsStates.loadingMore &&
        state.hasMore) {
      productsBloc.add(AddAdminProductsEvent(
        companyId: context.read<UsersBloc>().state.loggedUser.companyId,
        page: state.currentPage + 1,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge!.copyWith(color: Colors.black);
    final size = MediaQuery.of(context).size;
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        padding: const EdgeInsets.all(10),
        height: size.height,
        width: size.width,
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state.productsStates == ProductsStates.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state.productsStates == ProductsStates.error) {
              return Center(
                child: Text(translations.error,
                    style:
                        theme.textTheme.bodyLarge?.copyWith(color: Colors.red)),
              );
            }

            if (state.adminProducts.isEmpty) {
              return Center(
                child: Text(translations.no_products_found,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.black)),
              );
            }
            final uniqueProducts = <FilteredProduct>[];
            for (var product in state.adminProducts) {
              if (!uniqueProducts.any((p) => p.id == product.id)) {
                uniqueProducts.add(product);
              }
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.hasMore
                  ? uniqueProducts.length + 1
                  : uniqueProducts.length,
              itemBuilder: (context, index) {
                if (index >= uniqueProducts.length && state.hasMore) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                final product = uniqueProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductDetail(
                          product: product,
                          categories: categories.value,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                              image: product.mainPhotoUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          '${dotenv.env['PRODUCT_URL']}${product.mainPhotoUrl}'!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: product.mainPhotoUrl == null
                                ? const Icon(Icons.image_not_supported,
                                    color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Helpers.truncateText(product.name, 20),
                                  style: style.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Helpers.truncateText(
                                      product.brandName ?? '', 12),
                                  style: style.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  (() {
                                    if (product.categoryName != null) {
                                      final categories =
                                          jsonDecode(product.categoryName!)
                                              as List<dynamic>;
                                      return categories.firstWhere(
                                        (item) => item['language'] == language,
                                        orElse: () => {'text': ''},
                                      )['text'];
                                    }
                                    return '';
                                  })(),
                                  style: style.copyWith(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              DeleteProductDialog(productName: product.name)
                                  .showAlertDialog(
                                context,
                                translations,
                                theme,
                              )
                                  .then((value) {
                                if (value == true) {
                                  context
                                      .read<ProductsBloc>()
                                      .add(DeleteAdminProductEvent(
                                        productId: product.id,
                                      ));
                                }
                              });
                            },
                            icon:
                                Icon(Icons.delete, color: Colors.blueGrey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
