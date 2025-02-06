
import '../../../../../pages.dart';

enum ShippingRateMode{
  ADD,
  EDIT,
  SHOW
}

class ShippingRatePage extends StatelessWidget {
  ShippingRatePage({super.key});

  final ValueNotifier<ShippingRateMode> _shippingRateMode = ValueNotifier<ShippingRateMode>(ShippingRateMode.SHOW);
  final ValueNotifier<List<Map<String,dynamic>>> shippingRanges = ValueNotifier<List<Map<String,dynamic>>>([]);
  final ValueNotifier<List<FilteredProduct>> productIds = ValueNotifier<List<FilteredProduct>>([]);

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    const Widget spacer = SizedBox(height: 10.0);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ValueListenableBuilder(
          valueListenable: _shippingRateMode,
          builder: (BuildContext context, value, Widget? child) {
            return AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (value == ShippingRateMode.ADD || value == ShippingRateMode.EDIT) {
                    _shippingRateMode.value = ShippingRateMode.SHOW;
                    shippingRanges.value =  [];
                    productIds.value =  [];
                    context.read<ProductsBloc>().add(const ResetSearchedShippingRatesEvent());
                    //After reseting the state we need to clear the  
                    return;
                  }
                    context.pop();
                  
                },
              ),
              title: const Text('Shipping Rates'),
              actions: [
                if (value == ShippingRateMode.SHOW)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.read<ProductsBloc>().add(AddCountryGroupsByCompanyEvent(companyId: context.read<UsersBloc>().state.loggedUser.companyId));
                      _shippingRateMode.value = ShippingRateMode.ADD;
                    },
                  )
              ],
            );
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ValueListenableBuilder(
          valueListenable: _shippingRateMode,
          builder: (BuildContext context, ShippingRateMode value, Widget? child) {
            switch (value) {
              case ShippingRateMode.ADD:
                return ShippingRateForm(
                  formKey: _formKey, 
                  spacer: spacer, 
                  translations: translations, 
                  theme: theme, 
                  productIds: productIds, 
                  shippingRanges: shippingRanges
                );
              case ShippingRateMode.EDIT:
                return const Center(child: Text('Edit Shipping Rate'));
              case ShippingRateMode.SHOW:
                return child!;
            }
          },
          child: const ShippingRatesList(),
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _shippingRateMode,
        builder: (BuildContext context, value, Widget? child) {
          if (value == ShippingRateMode.SHOW) return const SizedBox.shrink();
          return child!;
        },
        child: CustomFloatingActionButton(
          child: const Icon(Icons.save, color: Colors.white),
          onClick: () {
            if (_formKey.currentState!.saveAndValidate()) {
              final List<Map<String, dynamic>> shippingRangesList = shippingRanges.value.map((range) {
                return {
                  'id': range['id'],
                  'quantityFrom': range['quantityFrom'],
                  'quantityTo': range['quantityTo'],
                  'price': range['price'],
                };
              }).toList();
              final List<String> pids = productIds.value.map((product) => product.id).toList();
              final Map<String, dynamic> data = {
                'name': _formKey.currentState!.value['name'],
                'countryGroupId': _formKey.currentState!.value['countryGroupId'],
                'countryId': _formKey.currentState!.value['countryId'],
                'productIds': pids,
                'productShippingRates': pids,
                'shippingRanges': shippingRangesList
              };
              context.read<ProductsBloc>().add(AddShippingRateEvent(body: data));
              _shippingRateMode.value = ShippingRateMode.SHOW;
            }
          },
        ),
      )
    );
  }
}

class ShippingRatesList extends StatefulWidget {
  const ShippingRatesList({
    super.key,
  });

  @override
  State<ShippingRatesList> createState() => _ShippingRatesListState();
}

class _ShippingRatesListState extends State<ShippingRatesList> {

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fetchShippingRates();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void fetchShippingRates() {
    context.read<ProductsBloc>().add(AddShippingRatesEvent(
        companyId: context.read<UsersBloc>().state.loggedUser.companyId, 
        page: 1
      )
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && context.read<ProductsBloc>().state.productsStates != ProductsStates.loadingMore) {
        context.read<ProductsBloc>().add(AddShippingRatesEvent(
            companyId: context.read<UsersBloc>().state.loggedUser.companyId, 
            page: context.read<ProductsBloc>().state.currentPage + 1
          )
        );
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
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(),
      height: size.height,
      width: size.width,
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state.productsStates == ProductsStates.loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
    
          if (state.productsStates == ProductsStates.error) {
            return Center(child: Text(translations.error, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)));
          }
    
          if (state.shippingRates.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(translations.no_shipping_rates_found, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black)),
                  // SizedBox(
                  //   width: size.width,
                  //   child: ElevatedButton(
                  //     onPressed: (){
                        
                  //     }, 
                  //     child: Text(translations.add(translations.shipping_rates), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                  //   ),
                  // )
                ]
              ),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            // itemCount: state.hasMore
            //             ? state.shippingRates.length + 1
            //             : state.shippingRates.length,
            itemCount: state.shippingRates.length,
            itemBuilder: (context, index) {
              // if (index >= state.shippingRates.length && state.hasMore) {
              //   return const Center(child: CircularProgressIndicator.adaptive());
              // }
              final FilteredShippingRate shippingRate = state.shippingRates[index];
              return ListTile(
                title: Text(shippingRate.name ?? 'No Name'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ShippingRateForm extends StatelessWidget {
  ShippingRateForm({
    super.key,
    required GlobalKey<FormBuilderState> formKey,
    required this.spacer,
    required this.translations,
    required this.theme,
    required this.productIds,
    required this.shippingRanges,
  }) : _formKey = formKey;

  final GlobalKey<FormBuilderState> _formKey;
  final Widget spacer;
  final AppLocalizations translations;
  final ThemeData theme;
  final ValueNotifier<List<FilteredProduct>> productIds;
  final ValueNotifier<List<Map<String, dynamic>>> shippingRanges;
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  // final ValueNotifier<List<FilteredProduct>> productsIdsSelected = ValueNotifier<List<FilteredProduct>>([]);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(height: size.height,
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spacer,
                FormBuilderTextField(
                  name: "name",
                  decoration: InputDecoration(
                    labelText: translations.name,
                    hintText: translations.enter_shipping_rate_name,
                  ),
                ),
                spacer,
                FormBuilderDropdown(
                  name: "countryGroupId",
                  decoration: InputDecoration(
                    labelText: translations.country_group,
                    hintText: translations.select_country_group,
                  ),
                  items: context.watch<ProductsBloc>().state.countryGroupsByCompany.map((CountryGroup countryGroup) {
                    return DropdownMenuItem(
                      value: countryGroup.id,
                      child: Text(countryGroup.name),
                    );
                  }).toList(),
                ),
                spacer,
                // FormBuilderDropdown(
                //   name: "countryId",
                //   decoration: InputDecoration(
                //     labelText: translations.country,
                //     hintText: translations.country,
                //   ),
                //   items: context.read<CountryBloc>().state.countries.map((Country country) {
                //     return DropdownMenuItem(
                //       value: country.id,
                //       child: Text(country.name),
                //     );
                //   }).toList(),
                // ),
                // spacer,
                spacer,
                Text(translations.shipping_rates, style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
                spacer,
                FormBuilderShippingRange(
                  name: 'shippingRanges', 
                  shippingRangesNotifier: shippingRanges,
                ),
                spacer,
                Text(translations.products, style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
                spacer,
                ValueListenableBuilder(
                  // valueListenable: productsIdsSelected,
                  valueListenable: productIds,
                  builder: (context, value, child) {
                    if(value.isEmpty){
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      height: size.height * 0.2,
                      width: size.width,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          children: value.map((id) {
                            final FilteredProduct product =value.firstWhere((opt) => opt.id == id.id);
                            return Chip(
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              label: Text(Helpers.truncateText(product.name, 20)),
                              onDeleted: () {
                                // productsIdsSelected.value = List.from(productsIdsSelected.value)..removeWhere((element) => element.id == product.id);
                                productIds.value = List.from(productIds.value)..removeWhere((element) => element.id == product.id);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                spacer,
                FormBuilderTextField(
                  name: "productIds",
                  decoration: InputDecoration(
                    labelText: translations.search,
                    hintText: translations.placeholder(translations.products),
                    suffixIcon: IconButton(
                      onPressed: (){
                        //clear the input value
                        _formKey.currentState!.fields['productIds']!.didChange('');
                        context.read<ProductsBloc>().add(const ResetSearchedShippingRatesEvent());
                      }, 
                      icon: const Icon(Icons.close)
                    )
                  ),
        
                  onChanged: (value) {
                    if ( value == null || value.trim().isEmpty) {
                      return;
                    }
                    _debouncer.run(() => context.read<ProductsBloc>().add(AddSearchProductShippingRatesEvent(query: value)));
                    
                  },
                ),
                // FormBuilderAutoComplete(
                //   name: 'productIds',
                //   selectedIdsNotifier: productIds,
                //   allOptions: context.watch<ProductsBloc>().state.searchProductShippingRates.map((FilteredProduct product) {
                //     return {
                //       'id': product.id,
                //       'name': product.name
                //     };
                //   }).toList(),
                // ),
                spacer,
                SizedBox(
                  height: size.height * 0.3,
                  width: size.width,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: context.watch<ProductsBloc>().state.searchProductShippingRates.length,
                    itemBuilder: (context, index) {
                      final FilteredProduct product = context.read<ProductsBloc>().state.searchProductShippingRates[index];
                      return ListTile(
                        title: Text(Helpers.truncateText(product.name, 20),),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            
                            if (productIds.value.contains(product)) {
                              return;
                            }
                            productIds.value = List.from(productIds.value)..add(product);
                            // productsIdsSelected.value = List.from(productsIdsSelected.value)..add(product);
                          },
                        ),
                      );
                    }
                  ),
                )
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class FormBuilderShippingRange extends StatelessWidget {
  final String name;
  final ValueNotifier<List<Map<String, dynamic>>> shippingRangesNotifier;

  const FormBuilderShippingRange({
    super.key,
    required this.name,
    required this.shippingRangesNotifier,
  });

  Widget _buildShippingRatesFields(int index, AppLocalizations translations) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: 'quantityFrom_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.from,
                hintText: translations.from,
              ),
              onChanged: (value) {
                if (shippingRangesNotifier.value.length > index) {
                  shippingRangesNotifier.value[index]['quantityFrom'] = int.tryParse(value!) ?? 0;
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              name: 'quantityTo_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.to,
                hintText: translations.to,
              ),
              onChanged: (value) {
                if (shippingRangesNotifier.value.length > index) {
                  shippingRangesNotifier.value[index]['quantityTo'] = int.tryParse(value!) ?? 0;
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              name: 'price_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.price,
                hintText: translations.price,
              ),
              onChanged: (value) {
                if (shippingRangesNotifier.value.length > index) {
                  shippingRangesNotifier.value[index]['price'] = double.tryParse(value!) ?? 0.0;
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              shippingRangesNotifier.value = List.from(shippingRangesNotifier.value)..removeAt(index);
              shippingRangesNotifier.value = List.from(shippingRangesNotifier.value).asMap().entries.map((entry) {
                final range = entry.value;
                return {
                  'id': range['id'],
                  'quantityFrom': range['quantityFrom'],
                  'quantityTo': range['quantityTo'],
                  'price': range['price']
                };
              }).toList();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 10.0),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: () {
              shippingRangesNotifier.value = List.from(shippingRangesNotifier.value)
                ..add({
                    'id': "", 
                    'quantityFrom': "", 
                    'quantityTo': "", 
                    'price': ""
                  }
                );
            },
            child: Text(translations.add(translations.shipping_rates.toLowerCase()), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: shippingRangesNotifier,
          builder: (context, value, child) {
            return Column(
              children: [
                const SizedBox(height: 10.0),
                ...List.generate(value.length, (index) => _buildShippingRatesFields(index, AppLocalizations.of(context)!))
              ],
            );
          },
        ),
      ],
    );
  }
}


class FormBuilderAutoComplete extends StatefulWidget {
  final String name;
  final ValueNotifier<List<String>> selectedIdsNotifier;
  final List<Map<String, String>> allOptions;

  const FormBuilderAutoComplete({
    super.key,
    required this.name,
    required this.selectedIdsNotifier,
    required this.allOptions,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FormBuilderAutoCompleteState createState() => _FormBuilderAutoCompleteState();
}

// class _FormBuilderAutoCompleteState extends State<FormBuilderAutoComplete> {

//   final Debouncer _debouncer = Debouncer(milliseconds: 500);

//   @override
//   Widget build(BuildContext context) {
//     return FormBuilderField<List<String>>(
//       name: widget.name,
//       initialValue: widget.selectedIdsNotifier.value,
//       builder: (FormFieldState<List<String>?> field) {
//         return Column(
//           children: [
//             Autocomplete<Map<String, String>>(
//               optionsBuilder: (TextEditingValue textEditingValue) {
//                 if (textEditingValue.text.isEmpty) {
//                   return const Iterable<Map<String, String>>.empty();
//                 }
//                 return widget.allOptions.where((option) {
//                   return option['name']!
//                       .toLowerCase()
//                       .contains(textEditingValue.text.toLowerCase());
//                 });
//               },
//               displayStringForOption: (Map<String, String> option) => option['name']!,
//               fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//                 return TextFormField(
//                   onFieldSubmitted: (value) => onFieldSubmitted(),
//                   controller: controller,
//                   focusNode: focusNode,
//                   decoration: InputDecoration(
//                     labelText: 'Search',
//                     hintText: 'Enter text to search',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                   ),
//                   validator:FormBuilderValidators.compose([
//                     FormBuilderValidators.minLength(3),
//                   ]),
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   onChanged: (value) {
//                     context.read<ProductsBloc>().add(const ResetSearchedShippingRatesEvent());
//                     if(value.length > 3){
//                       _debouncer.run(() => context.read<ProductsBloc>().add(AddSearchProductShippingRatesEvent(query: value)));
//                     }
//                   },
//                 );
//               },
//               onSelected: (Map<String, String> selectedOption) {
//                 if (!widget.selectedIdsNotifier.value.contains(selectedOption['id'])) {
//                   widget.selectedIdsNotifier.value = List.from(widget.selectedIdsNotifier.value)
//                     ..add(selectedOption['id']!);
//                 }
//                 field.didChange(widget.selectedIdsNotifier.value);
//               },
//               optionsViewBuilder: (context, onSelected, options) {
//                 return Align(
//                   alignment: Alignment.topLeft,
//                   child: Material(
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       child: ListView.builder(
//                         itemCount: options.length,
//                         itemBuilder: (context, index) {
//                           final option = options.elementAt(index);
//                           return ListTile(
//                             shape: const RoundedRectangleBorder(
//                               side: BorderSide.none,
//                             ),
//                             title: Text(option['name']!),
//                             onTap: () => onSelected(option), 
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 10),
//             ValueListenableBuilder<List<String>>(
//               valueListenable: widget.selectedIdsNotifier,
//               builder: (context, selectedIds, _) {
//                 return Wrap(
//                   spacing: 8.0,
//                   children: selectedIds.map((id) {
//                     final option = widget.allOptions.firstWhere((opt) => opt['id'] == id);
//                     return Chip(
//                       label: Text(option['name']!),
//                       onDeleted: () {
//                         widget.selectedIdsNotifier.value = List.from(widget.selectedIdsNotifier.value)
//                           ..remove(id);
//                         field.didChange(widget.selectedIdsNotifier.value);
//                       },
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }



class _FormBuilderAutoCompleteState extends State<FormBuilderAutoComplete> {
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: widget.name,
      initialValue: widget.selectedIdsNotifier.value,
      builder: (FormFieldState<List<String>?> field) {
        return Column(
          children: [
            BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                return Autocomplete<Map<String, String>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, String>>.empty();
                    }

                    return state.searchProductShippingRates.map((FilteredProduct product) {
                      return {
                        'id': product.id,
                        'name': product.name.trim().toLowerCase(),
                      };
                    }).where((option) {
                      return option['name']!.contains(textEditingValue.text.trim().toLowerCase());
                    }).toList();
                  },
                  displayStringForOption: (Map<String, String> option) => option['name']!,
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      onFieldSubmitted: (value) => onFieldSubmitted(),
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Enter text to search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.minLength(3),
                      ]),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        context.read<ProductsBloc>().add(const ResetSearchedShippingRatesEvent());
                        _debouncer.run(() => context.read<ProductsBloc>().add(AddSearchProductShippingRatesEvent(query: value)));
                      },
                    );
                  },
                  onSelected: (Map<String, String> selectedOption) {
                    if (!widget.selectedIdsNotifier.value.contains(selectedOption['id'])) {
                      widget.selectedIdsNotifier.value = List.from(widget.selectedIdsNotifier.value)
                        ..add(selectedOption['id']!);
                    }
                    field.didChange(widget.selectedIdsNotifier.value);
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide.none,
                                ),
                                title: Text(option['name']!),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<String>>(
              valueListenable: widget.selectedIdsNotifier,
              builder: (context, selectedIds, _) {
                return Wrap(
                  spacing: 8.0,
                  children: selectedIds.map((id) {
                    final option = context.read<ProductsBloc>().state.searchProductShippingRates.firstWhere((opt) => opt.id == id);
                    return Chip(
                      label: Text(option.name),
                      onDeleted: () {
                        widget.selectedIdsNotifier.value = List.from(widget.selectedIdsNotifier.value)
                          ..remove(id);
                        field.didChange(widget.selectedIdsNotifier.value);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
