
import 'dart:developer';

import '../../../../../pages.dart';

class AdminOffersPage extends StatefulWidget {
  const AdminOffersPage({super.key});

  @override
  State<AdminOffersPage> createState() => _AdminOffersPageState();
}

class _AdminOffersPageState extends State<AdminOffersPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ValueNotifier<bool> disabled = ValueNotifier<bool>(true);
  final Debouncer debouncer = Debouncer(milliseconds: 500);

  final ValueNotifier<List<FilteredProduct>> selectedProducts = ValueNotifier<List<FilteredProduct>>(<FilteredProduct>[]);

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(const AddFilteredOfferTypesEvent());
  }

  @override
  Widget build(BuildContext context) {
    // final AppLocalizations translations = AppLocalizations.of(context)!;
    const Widget spacer =  SizedBox(height: 10.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[ 
              FormBuilderDropdown(
                decoration: const InputDecoration(
                  labelText: 'Offer Type',
                  border: OutlineInputBorder(),
                ),
                name: "offer_type", 
                onChanged: (value) {
                  log('Offer Type: $value');
                  if (value != null) {
                    disabled.value = false;
                  } else {
                    disabled.value = true;
                  }
                },
                items: context.watch<ProductsBloc>().state.offerTypes.map((FilteredOfferTypes offerType) {
                  return DropdownMenuItem(
                    value: offerType.id,
                    child: Text(offerType.name ?? ''),
                  );
                }).toList(),
              ),
              spacer,
              Autocomplete<FilteredProduct>(
                displayStringForOption: (option) => option.name,
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return ValueListenableBuilder(
                    valueListenable: disabled,
                    builder: (BuildContext context, value, Widget? child) {
                      return TextFormField(
                        readOnly: value,
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          hintText: 'Enter product name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            debouncer.run(() {
                              context.read<ProductsBloc>().add(AddSearchProductOfferEvent(
                                query: value,
                                companyId: context.read<UsersBloc>().state.loggedUser.companyId,
                              ));
                            });
                          }
                        },
                      );
                    },
                  );
                },
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const [];
                  }
                  return context.read<ProductsBloc>().state.searchProductOffer;
                },
                onSelected: (filteredProduct) {
                  selectedProducts.value = List.from(selectedProducts.value)..add(filteredProduct);
                },
                
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: selectedProducts,
                  builder: (BuildContext context, value, Widget? child) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final FilteredProduct product = value[index];
                        return ListTile(
                          title: Text(product.name),
                        );
                      },
                    );
                  },
                )
              )
            ],
          ),
        ),
      )
    );
  }
}