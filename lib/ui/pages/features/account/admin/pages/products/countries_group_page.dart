import 'package:ourshop_ecommerce/ui/pages/pages.dart';


enum CountryGroupPageMode{
  EDIT,
  ADD,
  SHOW
}

class CountryGroupPage extends StatefulWidget {
  const CountryGroupPage({super.key});

  @override
  State<CountryGroupPage> createState() => _CountryGroupPageState();
}

class _CountryGroupPageState extends State<CountryGroupPage> {

  late ScrollController _scrollController;
  @override
  void initState() {  
    // dispacth the event to get the countries group
    fetchCountriesGroups();
    _scrollController = ScrollController()..addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(listener);
    super.dispose();
  }

  void listener() {
    final double threshold = _scrollController.position.maxScrollExtent * 0.1;
    if (_scrollController.position.pixels >= threshold && 
        context.read<ProductsBloc>().state.hasMore && 
        context.read<ProductsBloc>().state.productsStates != ProductsStates.loadingMore) {
      fetchCountriesGroups();
    }
  }

    void fetchCountriesGroups() {
    context.read<ProductsBloc>().add(AddFilteredCountriesGrupoEvent(
      page: context.read<ProductsBloc>().state.currentPage + 1,
      companyId: context.read<UsersBloc>().state.loggedUser.companyId,
    ));
  }

  final ValueNotifier<CountryGroupPageMode> mode = ValueNotifier<CountryGroupPageMode>(CountryGroupPageMode.SHOW);
  final ValueNotifier<FilteredGroupCountries> selectedFilteredCountry = ValueNotifier<FilteredGroupCountries>(const FilteredGroupCountries(name: '', countries: [], id: '', countriesIds: null));
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ValueListenableBuilder(
          valueListenable: mode,
          builder: (BuildContext context, value, Widget? child) {
            return AppBar(
              leading: IconButton(
                onPressed:(){
                  if (value == CountryGroupPageMode.EDIT || value == CountryGroupPageMode.ADD) {
                    mode.value = CountryGroupPageMode.SHOW;
                    return;
                  }
                  context.pop();
                }, 
                icon: const Icon(Icons.arrow_back)
              ),
              title: Text('${translations.countries_group} ${context.watch<ProductsBloc>().state.groupCountries.length}', style: theme.textTheme.titleLarge),
              actions: [
                if (value == CountryGroupPageMode.SHOW)
                  IconButton(
                    onPressed: () {
                      selectedFilteredCountry.value = const FilteredGroupCountries(name: '', countries: [], id: '', countriesIds: null);
                      mode.value = CountryGroupPageMode.ADD;
                    },
                    icon: const Icon(Icons.add),
                  )
              ],
            );
          },
        ),
      ),
      body: ValueListenableBuilder<CountryGroupPageMode>(
        valueListenable: mode,
        builder: (BuildContext context, value, Widget? child) {
          switch (value) {
            case CountryGroupPageMode.EDIT:
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CountryGroupForm(
                  formKey: _formKey, 
                  selectedFilteredCountry: selectedFilteredCountry, 
                  mode: CountryGroupPageMode.EDIT,
                ),
              );
            case CountryGroupPageMode.ADD:
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CountryGroupForm(
                  formKey: _formKey, 
                  selectedFilteredCountry: selectedFilteredCountry,
                  mode: CountryGroupPageMode.ADD,
                ),
              );
            default:
              return child!;
          }
        },
        child: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state.productsStates == ProductsStates.loading || state.productsStates == ProductsStates.updating) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
        
            if (state.productsStates == ProductsStates.error) {
              return Center(
                child: Text(translations.error, style: theme.textTheme.titleMedium),
              );
            }
        
            if (state.productsStates == ProductsStates.loaded && state.groupCountries.isEmpty) {
              return Center(
                child: Text(translations.no_coutnries_group, style: theme.textTheme.titleMedium),
              );
            }
        
            return SizedBox(
              height: size.height,
              width: size.width,
              child: ListView.builder(
                controller: _scrollController,
                itemCount:state.hasMore
                  ? state.groupCountries.length + 1
                  : state.groupCountries.length,
                itemBuilder: (context, index) {
                  if (index == state.groupCountries.length) {
                    return const Center(child: CircularProgressIndicator.adaptive());
                  }
                  final FilteredGroupCountries groupCountry = state.groupCountries[index];
                  return Container(
                    
                    height: size.height * 0.1,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0, 3),
                          color: Colors.grey,
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(groupCountry.name, style: theme.textTheme.titleMedium),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                selectedFilteredCountry.value = groupCountry;
                                mode.value = CountryGroupPageMode.EDIT;
                              },
                              icon: const Icon(Icons.edit)
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.03,
                          width: size.width,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: groupCountry.countries.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final Country country = groupCountry.countries[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(country.name)
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, 
              ),
            );
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: mode,
        builder: (BuildContext context, value, Widget? child) {
          if(value == CountryGroupPageMode.SHOW) {
            return const SizedBox.shrink();
          }
          return BlocBuilder<ProductsBloc, ProductsState>(
            buildWhen: (previous, current) => previous.productsStates != current.productsStates,
            builder: (context, state) {
              return FloatingActionButton(
                onPressed:state.productsStates == ProductsStates.updating ? null : () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final Map<String, dynamic> data = {};
                    // data['countries'] = selectedFilteredCountry.value.countries;
                    data['name'] = _formKey.currentState!.value['name'];
                    if (value == CountryGroupPageMode.EDIT) {
                      data['id'] = selectedFilteredCountry.value.id;
                      data['countries'] = selectedFilteredCountry.value.countriesIds;
                      context.read<ProductsBloc>().add(UpdateCountryGroupEvent(
                          countryGroupId: selectedFilteredCountry.value.id,
                          body: data
                        )
                      );
                      mode.value = CountryGroupPageMode.SHOW;
                      return;
                    }
                    data['countriesIds'] = selectedFilteredCountry.value.countriesIds;
                    context.read<ProductsBloc>().add(AddNewCountryGroupEvent(body: data));
                  }
                  mode.value = CountryGroupPageMode.SHOW;
                },
                child: state.productsStates == ProductsStates.updating ? CircularProgressIndicator.adaptive(backgroundColor: AppTheme.palette[550],) : const Icon(Icons.save, color: Colors.white,),
              );
            },
          );
        },
      ),
    );
  }
}

class CountryGroupForm extends StatelessWidget {
  const CountryGroupForm({
    super.key,
    required GlobalKey<FormBuilderState> formKey,
    required this.selectedFilteredCountry,
    required this.mode,
  }) : _formKey = formKey;

  final GlobalKey<FormBuilderState> _formKey;
  final ValueNotifier<FilteredGroupCountries> selectedFilteredCountry;
  final CountryGroupPageMode mode;


  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10,),
          FormBuilderTextField(
            initialValue: mode == CountryGroupPageMode.ADD ? '' : selectedFilteredCountry.value.name,
            name: "name",
            decoration: InputDecoration(
              labelText: translations.name,
              hintText: translations.name,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 10,),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(translations.countries, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 10,),
          FormBuilderDropdown(
            name: "include_country", 
            decoration: InputDecoration(
              labelText: translations.choose_country,
              hintText: translations.choose_country,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            items: context.read<CountryBloc>().state.countries.map((Country country) => DropdownMenuItem(
              value: country.id,
              child: Text(country.name),
            )).toList(),
            onChanged: (String? countryId) {
              if (countryId != null) {
                final Country selectedCountry = context.read<CountryBloc>().state.countries.firstWhere((country) => country.id == countryId,);
                final updatedCountries = List<Country>.from(selectedFilteredCountry.value.countries);
                if (!updatedCountries.contains(selectedCountry)) {
                  updatedCountries.add(selectedCountry);
                  selectedFilteredCountry.value = selectedFilteredCountry.value.copyWith(
                    countries: updatedCountries, 
                    countriesIds: updatedCountries.map((country) => country.id).toList()
                  );
                }
              }
            },
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: selectedFilteredCountry,
              builder: (BuildContext context, value, Widget? child) {
                return ListView.builder(
                  itemCount: value.countries.length,
                  itemBuilder: (context, index) {
                    final Country country = value.countries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: ListTile(
                        title: Text(country.name),
                        trailing: IconButton(
                          onPressed: () {
                            final updatedCountries = List<Country>.from(value.countries);
                            updatedCountries.removeAt(index);
                            selectedFilteredCountry.value = value.copyWith(
                              countries: updatedCountries,
                              countriesIds: updatedCountries.map((country) => country.id).toList()
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      )
    );
  }
}