part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class AddProductsStatesEvent extends ProductsEvent {
  final ProductsStates productsState;
  const AddProductsStatesEvent({required this.productsState});
  @override
  List<Object> get props => [productsState];
}

class AddCategoriesEvent extends ProductsEvent {
  const AddCategoriesEvent();
  @override
  List<Object> get props => [];
}

class AddProductsEvent extends ProductsEvent {
  final List<Product> products;
  const AddProductsEvent(this.products);
  @override
  List<Object> get props => [products];
}

class ChangeGridCountEvent extends ProductsEvent {
  final int gridCount;
  const ChangeGridCountEvent(this.gridCount);
  @override
  List<Object> get props => [gridCount];
}

class AddFavoriteProductEvent extends ProductsEvent {
  final FilteredProduct product;
  const AddFavoriteProductEvent(this.product);
  @override
  List<Object> get props => [product];
}

class AddCartProductEvent extends ProductsEvent {
  final FilteredProduct product;
  const AddCartProductEvent({required this.product});
  @override
  List<Object> get props => [product];
}

class RemoveCartProductEvent extends ProductsEvent {
  final FilteredProduct product;
  const RemoveCartProductEvent({required this.product});
  @override
  List<Object> get props => [product];
}
class AddSelectedParentCategoryEvent extends ProductsEvent {
  final String selectedParentCategory;
  const AddSelectedParentCategoryEvent({required this.selectedParentCategory});
  @override
  List<Object> get props => [selectedParentCategory];
}

class SelectAllCartProductsEvent extends ProductsEvent {
  const SelectAllCartProductsEvent();
  @override
  List<Object> get props => [];
}

class DeselectAllCartProductsEvent extends ProductsEvent {
  const DeselectAllCartProductsEvent();
  @override
  List<Object> get props => [];
}

class SelectOrDeselectCartProductEvent extends ProductsEvent {
  final FilteredProduct product;
  const SelectOrDeselectCartProductEvent({required this.product});
  @override
  List<Object> get props => [product];
}

class ClearCart extends ProductsEvent {
  const ClearCart();
  @override
  List<Object> get props => [];
}


class AddCategoryHeaderImagesEvent extends ProductsEvent {
  final List<String> categoryHeaderImages;
  const AddCategoryHeaderImagesEvent({required this.categoryHeaderImages});
  @override
  List<Object> get props => [categoryHeaderImages];
}

class AddSelectedSubCategoryEvent extends ProductsEvent {
  final String selectedSubCategoryId;
  const AddSelectedSubCategoryEvent({required this.selectedSubCategoryId});
  @override
  List<Object> get props => [selectedSubCategoryId];
}

class AddSubCategoryProductsEvent extends ProductsEvent {
  final FilteredResponseMode mode;
  final int page;
  const AddSubCategoryProductsEvent({required this.mode, required this.page});
  @override
  List<Object> get props => [mode, page];
}

class AddSubCategoriesEvent extends ProductsEvent {
  final String categoryId;
  const AddSubCategoriesEvent({required this.categoryId});
  @override
  List<Object> get props => [categoryId];
}

class AddAdminProductsEvent extends ProductsEvent {
  final String companyId;
  final int page;
  const AddAdminProductsEvent({required this.companyId, required this.page});
  @override
  List<Object> get props => [companyId, page];
}

class DeleteAdminProductEvent extends ProductsEvent {
  final String productId;
  const DeleteAdminProductEvent({required this.productId});
  @override
  List<Object> get props => [productId];
}

class AddFilteredProductsSuggestionsEvent extends ProductsEvent {
  final int page;
  const AddFilteredProductsSuggestionsEvent({required this.page});
  @override
  List<Object> get props => [page];
}

class AddFilteredBuildResultsEvent extends ProductsEvent {
  final String query;
  final int page;
  const AddFilteredBuildResultsEvent({required this.query, required this.page});
  @override
  List<Object> get props => [query, page];
}

class ResetStatesEvent extends ProductsEvent {
  const ResetStatesEvent();
  @override
  List<Object> get props => [];
}

class AddFilteredProductsEvent extends ProductsEvent {
  final FilteredResponseMode mode;
  final String categoryId;
  final int page;
  const AddFilteredProductsEvent({required this.page, required this.mode, required this.categoryId});
  @override
  List<Object> get props => [page, mode, categoryId];
}

class AddFilteredCountriesGrupoEvent extends ProductsEvent {
  final int page;
  final String companyId;
  const AddFilteredCountriesGrupoEvent({required this.page, required this.companyId});
  @override
  List<Object> get props => [page, companyId];
}

class AddNewCountryGroupEvent extends ProductsEvent {
  final Map<String, dynamic> body;
  const AddNewCountryGroupEvent({required this.body});
  @override
  List<Object> get props => [body];
}

class UpdateCountryGroupEvent extends ProductsEvent {
  final String countryGroupId;
  final Map<String, dynamic> body;
  const UpdateCountryGroupEvent({required this.countryGroupId, required this.body});
  @override
  List<Object> get props => [countryGroupId, body];
}

class AddSubCategoriesNewProductEvent extends ProductsEvent {
  final String categoryId;
  const AddSubCategoriesNewProductEvent({required this.categoryId});
  @override
  List<Object> get props => [categoryId];
}

class AddNewProductEvent extends ProductsEvent {
  final FormData form;
  const AddNewProductEvent({required this.form});
  @override
  List<Object> get props => [form];
}

class AddShippingRatesEvent extends ProductsEvent {
  final String companyId;
  final int page;
  const AddShippingRatesEvent({required this.companyId, required this.page});
  @override
  List<Object> get props => [companyId, page];
}

class AddCountryGroupsByCompanyEvent extends ProductsEvent {
  final String companyId;
  const AddCountryGroupsByCompanyEvent({required this.companyId});
  @override
  List<Object> get props => [companyId];
}

class AddShippingRateEvent extends ProductsEvent {
  final Map<String, dynamic> body;
  const AddShippingRateEvent({required this.body});
  @override
  List<Object> get props => [body];
}

class AddFilteredOfferTypesEvent extends ProductsEvent {
  const AddFilteredOfferTypesEvent();
  @override
  List<Object> get props => [];
}

class AddSearchProductOfferEvent extends ProductsEvent {
  final String query;
  final String companyId;
  const AddSearchProductOfferEvent({required this.query, required this.companyId});
  @override
  List<Object> get props => [query, companyId];
}

class AddSearchProductShippingRatesEvent extends ProductsEvent {
  final String query;
  // final String companyId;
  const AddSearchProductShippingRatesEvent({required this.query});
  @override
  List<Object> get props => [query];
}

class ResetSearchedShippingRatesEvent extends ProductsEvent {
  const ResetSearchedShippingRatesEvent();
  @override
  List<Object> get props => [];
}

class CalculateShippingRateEvent extends ProductsEvent {
  final Map<String, dynamic> body;
  const CalculateShippingRateEvent({required this.body});
  @override
  List<Object> get props => [body];
}

class AddOfferProductEvent extends ProductsEvent {
  final int page;
  const AddOfferProductEvent({required this.page});
  @override
  List<Object> get props => [page];
}