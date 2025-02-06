import 'dart:developer';

import '../ui/pages/pages.dart';

class Observable extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (bloc is SettingsBloc) {
      final currentState = change.currentState as SettingsState;
      final nextState = change.nextState as SettingsState;
      if (currentState.currentLanguage != nextState.currentLanguage) {
        // log('Language changed to ${nextState.currentLanguege}');
      }
    } else if (bloc is RolesBloc) {
      final currentState = change.currentState as RolesState;
      final nextState = change.nextState as RolesState;
      if (currentState.roles.length != nextState.roles.length) {
        // log('Roles changed to ${nextState.roles}');
      }
    } else if (bloc is CompanyBloc) {
      final currentState = change.currentState as CompanyState;
      final nextState = change.nextState as CompanyState;
      if (currentState.socialMedias.length != nextState.socialMedias.length) {
        log('social medias ${nextState.socialMedias.length}');
      }
    } else if (bloc is UsersBloc) {
      final currentState = change.currentState as UsersState;
      final nextState = change.nextState as UsersState;
      if (currentState.loggedUser != nextState.loggedUser) {
        // log('User changed to ${nextState.loggedUser}');
      }
    } else if (bloc is ProductsBloc){
      final currentState = change.currentState as ProductsState;
      final nextState = change.nextState as ProductsState;
      // if(currentState.subCategoriesNewProduct != nextState.subCategoriesNewProduct) {
      //   log('subCategoriesNewProduct: ${nextState.subCategoriesNewProduct.length}');
      // }
      // if(currentState.productGroups != nextState.productGroups) {
      //   log('productGroups: ${nextState.productGroups.length}');
      // }
      // if(currentState.productTypes != nextState.productTypes) {
      //   log('productTypes: ${nextState.productTypes.length}');
      // }
      // if(currentState.unitMeasurements != nextState.unitMeasurements) {
      //   log('unitMeasurements: ${nextState.unitMeasurements.length}');
      // }
      // if(currentState.filteredBuildResults != nextState.filteredBuildResults) {
      //   log('filteredBuildResults: ${nextState.filteredBuildResults.length}');
      // }
      // if(currentState.currentPage != nextState.currentPage) {
      //   log('filteredProductCurerntPage: ${nextState.currentPage}');
      // }
      // if (currentState.suggestionsCurrentPage != nextState.suggestionsCurrentPage){
      //   log('suggestionsCurrentPage: ${nextState.suggestionsCurrentPage}');
      // }
      // if (currentState.resultsCurrentPage != nextState.resultsCurrentPage){
      //   log('suggestionsCurrentPage: ${nextState.resultsCurrentPage}');
      // }

      // if(currentState.filteredProducts != nextState.filteredProducts) {
      //   log('filteredProducts:${nextState.filteredProducts.length}');
      // }
      if(currentState.selectedParentCategory != nextState.selectedParentCategory) {
        log('selectedParentCategory:${nextState.selectedParentCategory}');
      }
      if (currentState.selectedSubCategory != nextState.selectedSubCategory){

        log('selectedSubCategory: ${nextState.selectedSubCategory.name}');
        // log('selectedSubCategory parent id: ${nextState.selectedSubCategory.parentCategoryId}');
      }

      if (currentState.searchProductShippingRates != nextState.searchProductShippingRates){
        log('searchProductShippingRates: ${nextState.searchProductShippingRates}');

      }
    } else if (bloc is OrdersBloc){
      final currentState = change.currentState as OrdersState;
      final nextState = change.nextState as OrdersState;
      if (currentState.filteredAdminOrders != nextState.filteredAdminOrders) {
        // log('Orders changed to ${nextState.filteredAdminOrders}');
      }
    } else if (bloc is GeneralBloc){
      final currentState = change.currentState as GeneralState;
      final nextState = change.nextState as GeneralState;
      if (currentState.keyboardVisible != nextState.keyboardVisible) {
        // log('keyboardVisible changed to ${nextState.keyboardVisible}');
      }
    }
  }
}