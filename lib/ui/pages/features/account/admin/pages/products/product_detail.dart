import 'dart:convert';

import '../../../../../pages.dart';

enum AdminProductMode { EDIT, NEW }

class AdminProductDetail extends StatefulWidget {
  final List<Category>? categories;

  const AdminProductDetail({super.key, required this.product, this.categories});

  final FilteredProduct product;

  @override
  State<AdminProductDetail> createState() => _AdminProductDetailState();
}

class _AdminProductDetailState extends State<AdminProductDetail> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  ValueNotifier<List<Category>> categories = ValueNotifier([]);
  final ProductService _productService = locator<ProductService>();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        categories.value = widget.categories!;
      });
    });
    context.read<ProductsBloc>().add(AddSubCategoriesNewProductEvent(
        categoryId:
            context.read<UsersBloc>().state.loggedUser.companyMainCategoryId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Helpers.truncateText(widget.product.name, 30)),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.save,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final formData = _formKey.currentState!.value;
              guardarProducto(formData);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Por favor, completa los campos requeridos.')),
              );
            }
          }),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ProductForm(
              formKey: _formKey,
              mode: AdminProductMode.EDIT,
              product: widget.product,
              categories: categories.value,
            ),
    );
  }

  Future<void> guardarProducto(Map<String, dynamic> formData) async {
    Map<String, dynamic> data = {};
    FormData formDataObj = FormData();

    data['product'] = <String, dynamic>{};
    List<Map<String, dynamic>> priceByQuantity = [];
    if (formData['priceOptions'] == 2) {
      formData.forEach((key, value) {
        if (key.startsWith('from_')) {
          final index = key.split('_').last;
          priceByQuantity.add({
            'quantityFrom': value,
            'quantityTo': formData['to_$index'],
            'price': formData['price_$index']
          });
        }
      });
    }
    data['product'].addAll({
      "name": formData['name'] ?? '',
      "categoryId": formData['categoryId'] ?? '',
      "subCategoryId": formData['subCategoryId'] ?? '',
      "productGroupId": formData['productGroupId'] ?? '',
      "productTypeId": formData['productTypeId'] ?? '',
      "unitMeasurementId": formData['unitMeasurementId'] ?? '',
      "modelNumber": formData['modelNumber'] ?? '',
      'moqUnit': formData['moqUnit'] ?? '',
      'fboPriceStart': formData['fboPriceStart'],
      'fboPriceEnd': formData['fboPriceEnd'],
      'usePriceRange': formData['priceOptions'] == 2,
      "brandName": formData['brandName'] ?? '',
      "keyValue": formData['keyValue'] ?? '',
      "unitPrice": (formData['unitPrice'] ?? 0).toString(),
      'priceByQuantity': priceByQuantity,
      'priceType': formData['priceType'],
      'photos': formData['photos'] != null ? [] : [],
      'videos': formData['videos'] != null ? [] : [],
      "stock": (formData['stock'] ?? 0).toString(),
      "packageLength": (formData['packageLength'] ?? 0).toString(),
      "packageWidth": (formData['packageWidth'] ?? 0).toString(),
      "packageHeight": (formData['packageHeight'] ?? 0).toString(),
      "packageWeight": (formData['packageWeight'] ?? 0).toString(),
      'priceRanges': formData['priceRanges'] ?? [],
    });

    List<Map<String, String>> details = [];
    List<Map<String, String>> specifications = [];
    List<Map<String, String>> certifications = [];

    int index = 0;
    int indexSpecific = 0;
    int indexCertifi = 0;
    while (formData.containsKey("detailName_$index") &&
        formData.containsKey("detailDescription_$index")) {
      details.add({
        "name": formData["detailName_$index"] ?? '',
        "description": formData["detailDescription_$index"] ?? '',
      });
      index++;
    }
    while (formData.containsKey("specificationName_$indexSpecific")) {
      specifications.add({
        "name": formData["specificationName_$indexSpecific"] ?? '',
      });
      indexSpecific++;
    }

    while (formData.containsKey("certificationName_$indexCertifi") &&
        formData.containsKey("detailDescription_$indexCertifi")) {
      certifications.add({
        "name": formData["certificationNumber_$indexCertifi"] ?? '',
        "certificationNumber":
            formData["certificationNumber_$indexCertifi"] ?? ''
      });
      indexCertifi++;
    }

    data['product']["details"] = details;
    data['product']["specifications"] = specifications;
    data['product']["certifications"] = certifications;

    formDataObj.fields.add(MapEntry('product', jsonEncode(data)));
    if (formData['photos'] != null && formData['photos'].isNotEmpty) {
      for (var file in formData['photos']) {
        formDataObj.files.add(MapEntry(
          'newPhotos',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }
    }
    if (formData['videos'] != null && formData['videos'].isNotEmpty) {
      for (var file in formData['videos']) {
        formDataObj.files.add(MapEntry(
          'newVideos',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }
    }
    try {
      final String token = locator<Preferences>().preferences['refreshToken'];
      await _productService.updateProduct(
          formDataObj, token, widget.product.id);
    } catch (e) {
      print("Error al guardar el producto: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el producto.')));
    }
    // Enviar la solicitud
    /*   try {
      final response = await Dio().post("URL_DE_API_AQUI", data: data);
      print("Respuesta del servidor: ${response.data}");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto guardado exitosamente.')));
    } catch (e) {
      print("Error al guardar el producto: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el producto.')));
    } */
  }
}

class Option {
  final int value;
  final String text;

  Option({required this.value, required this.text});
}

class ProductForm extends StatelessWidget {
  ProductForm({
    super.key,
    required GlobalKey<FormBuilderState> formKey,
    this.product,
    required this.mode,
    this.categories,
  })  : assert(!(mode == AdminProductMode.EDIT && product == null),
            'Edit mode needs a product to continue'),
        _formKey = formKey;

  final AdminProductMode mode;
  final FilteredProduct? product;
  final List<Category>? categories;

  final GlobalKey<FormBuilderState> _formKey;
  final ValueNotifier<int> option = ValueNotifier<int>(0);

  final ValueNotifier<List<File>> selectedPhotos =
      ValueNotifier<List<File>>([]);
  final ValueNotifier<List<File>> selectedVideos =
      ValueNotifier<List<File>>([]);

  final ValueNotifier<List<Map<String, String>>> details =
      ValueNotifier<List<Map<String, String>>>([]);
  final ValueNotifier<List<Widget>> certifications =
      ValueNotifier<List<Widget>>([]);

  final ValueNotifier<List<Widget>> specifications =
      ValueNotifier<List<Widget>>([]);
  final ValueNotifier<List<Category>> subCategories =
      ValueNotifier<List<Category>>([]);

  final ValueNotifier<List<Widget>> priceRanges =
      ValueNotifier<List<Widget>>([]);
  ValueNotifier<List<Category>> categoriesNotifier =
      ValueNotifier<List<Category>>([]);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    final List<Option> options = [
      Option(value: 0, text: translations.unit_price('')),
      Option(value: 1, text: translations.price_range),
      Option(value: 2, text: translations.price_by_quantity),
    ];
    Widget spacer = const SizedBox(height: 10.0);
    final ThemeData theme = Theme.of(context);
    final TextStyle style =
        theme.textTheme.bodyLarge!.copyWith(color: Colors.black);
    final Size size = MediaQuery.of(context).size;
    categoriesNotifier.value = categories!;

    if (product != null && mode == AdminProductMode.EDIT) {}
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacer,
              FormBuilderTextField(
                initialValue: product != null ? product!.name : '',
                name: 'name',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(labelText: translations.name),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              spacer,
              Text(
                translations.general,
                style: style.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              spacer,
              ValueListenableBuilder(
                  valueListenable: categoriesNotifier,
                  builder: (BuildContext context, value, Widget? child) {
                    return FormBuilderDropdown(
                      //initialValue: product != null ? product!.categoryId : '',
                      name: 'categoryId',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      decoration: InputDecoration(
                        labelText: translations.category,
                        hintText: translations.category,
                      ),
                      onChanged: (value) async {
                        final categoriesSecond =
                            await locator<CategoryService>()
                                .getCategoryById(value!);
                        locator<ProductService>().getProductGroups();
                        if (categoriesSecond is List<Category>) {
                          subCategories.value = categoriesSecond;
                        }
                      },
                      items: categories!
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ))
                          .toList(),
                    );
                  }),
              spacer,
              ValueListenableBuilder(
                valueListenable: subCategories,
                builder: (BuildContext context, value, Widget? child) {
                  return FormBuilderDropdown(
                    //initialValue: product != null ? product!.categoryId : '',
                    name: 'categoryId',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    decoration: InputDecoration(
                      labelText: translations.sub_categories,
                      hintText: translations.sub_categories,
                    ),
                    items: value
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.name),
                            ))
                        .toList(),
                  );
                },
              ),
              spacer,
              ValueListenableBuilder(
                  valueListenable: subCategories,
                  builder: (BuildContext context, value, Widget? child) {
                    return FormBuilderDropdown(
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      //initialValue:
                      //product != null ? product!.productGroupId : '',
                      name: 'productGroupId',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: translations.product_group,
                        hintText: translations.product_group,
                      ),
                      items: context
                          .watch<ProductsBloc>()
                          .state
                          .productGroups
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ))
                          .toList(),
                    );
                  }),
              spacer,
              FormBuilderDropdown(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: product != null ? product!.productTypeId : '',
                name: 'productTypeId',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: translations.product_type,
                  hintText: translations.product_type,
                ),
                items: context
                    .watch<ProductsBloc>()
                    .state
                    .productTypes
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.name),
                        ))
                    .toList(),
              ),
              spacer,
              FormBuilderDropdown(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: product != null ? product!.unitMeasurementId : '',
                name: 'unitMeasurementId',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: translations.product_unit,
                  hintText: translations.product_unit,
                ),
                items: context
                    .watch<ProductsBloc>()
                    .state
                    .unitMeasurements
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.name),
                        ))
                    .toList(),
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: product != null ? product!.modelNumber : '',
                name: 'modelNumber',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.model_number,
                    hintText: translations.model_number),
              ),
              spacer,
              FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: product != null ? product!.brandName : '',
                name: 'brandName',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.brand_name,
                    hintText: translations.brand_name),
              ),
              spacer,
              FormBuilderTextField(
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                initialValue: product != null ? product!.keyValue : '',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: 'keyValue',
                decoration: InputDecoration(
                    labelText: translations.key_value,
                    hintText: translations.key_value),
              ),
              ValueListenableBuilder(
                valueListenable: option,
                builder: (context, value, child) {
                  return Offstage(
                    offstage: true,
                    child: FormBuilderTextField(
                      name: 'priceType',
                      initialValue: value == 0
                          ? 'unitPrice'
                          : value == 1
                              ? 'priceRange'
                              : 'priceByQuantity',
                    ),
                  );
                },
              ),
              spacer,
              FormBuilderOptionsPicker(
                name: 'priceOptions',
                labelText: '',
                options: options,
                selectedOption: option,
                extraFields: priceRanges,
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                initialValue: product != null ? product!.stock.toString() : '',
                name: "stock",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.inventory,
                    hintText: translations.inventory),
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                initialValue:
                    product != null ? product!.packageLength.toString() : '',
                name: "packageLength",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.package_length,
                    hintText: translations.package_length),
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                initialValue:
                    product != null ? product!.packageWidth.toString() : '',
                name: "packageWidth",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.package_width,
                    hintText: translations.package_width),
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                initialValue:
                    product != null ? product!.packageHeight.toString() : '',
                name: "packageHeight",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.package_height,
                    hintText: translations.package_height),
              ),
              spacer,
              FormBuilderTextField(
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                initialValue:
                    product != null ? product!.packageWeight.toString() : '',
                name: "packageWeight",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: translations.package_weight,
                    hintText: translations.package_weight),
              ),
              spacer,
              Text(
                translations.photos,
                style: style.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              spacer,
              FormBuilderFilePicker(
                name: 'photos',
                labelText: translations.choose_photos,
                selectedFiles: selectedPhotos,
                onFilePick: () async {
                  return await context
                      .read<ProductsBloc>()
                      .chooseAdminProductPhotos();
                },
                validator: FormBuilderValidators.compose([
                  (value) {
                    if (value == null || value.isEmpty) {
                      return translations.selected_photos_error;
                    }
                    return null;
                  },
                ]),
              ),
              spacer,
              Text(
                translations.videos,
                style: style.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              spacer,
              FormBuilderVideoPicker(
                name: 'videos',
                labelText: translations.choose_videos,
                selectedVideos: selectedVideos,
                onVideoPick: () =>
                    context.read<ProductsBloc>().chooseAdminProductVideos(),
              ),
              spacer,
              Text(
                translations.details,
                style: style.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600),
              ),
              spacer,
              FormBuilderDetails(
                name: 'details',
                detailsNotifier: details,
              ),
              spacer,
              FormBuilderSpecifications(
                name: 'specifications',
                specificationFields: specifications,
              ),
              spacer,
              FormBuilderCertifications(
                name: 'certifications',
                certificationFields: certifications,
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addPriceRange(Size size, TextStyle style) {
    final int index = priceRanges.value.length;
    priceRanges.value = List.from(priceRanges.value)
      ..add(Column(
        key: ValueKey(index),
        children: [
          Row(
            key: ValueKey(index),
            children: [
              Expanded(
                child: FormBuilderTextField(
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  name: 'cantidad_desde_$index',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      labelText: 'Cantidad desde', hintText: 'Cantidad desde'),
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  name: 'cantidad_hasta_$index',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      labelText: 'Cantidad hasta', hintText: 'Cantidad hasta'),
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  name: 'precio_$index',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      labelText: 'precio', hintText: 'precio'),
                ),
              ),
              IconButton(
                onPressed: () => removePriceRange(index),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ));
  }

  void removePriceRange(int index) {
    priceRanges.value = List.from(priceRanges.value)..removeAt(index);
    for (int i = 0; i < priceRanges.value.length; i++) {
      priceRanges.value[i] = _buildPriceRangeRow(i);
    }
  }

  Widget _buildPriceRangeRow(int index) {
    return Row(
      key: ValueKey(index),
      children: [
        Expanded(
          child: FormBuilderTextField(
            keyboardType: TextInputType.number,
            name: 'cantidad_desde_$index',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
                labelText: 'Cantidad desde', hintText: 'Cantidad desde'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FormBuilderTextField(
            keyboardType: TextInputType.number,
            name: 'cantidad_hasta_$index',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
                labelText: 'Cantidad hasta', hintText: 'Cantidad hasta'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FormBuilderTextField(
            keyboardType: TextInputType.number,
            name: 'precio_$index',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration:
                const InputDecoration(labelText: 'precio', hintText: 'precio'),
          ),
        ),
        IconButton(
          onPressed: () => removePriceRange(index),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }
}

class _VideoThumbnailWidget extends StatefulWidget {
  final File file;

  const _VideoThumbnailWidget({required this.file});

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {}); // Actualiza el estado cuando el video esté listo
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator.adaptive());
  }
}

class FormBuilderFilePicker extends FormBuilderField<List<File>> {
  final String labelText;
  final ValueNotifier<List<File>> selectedFiles;
  final Future<List<File>> Function() onFilePick;

  FormBuilderFilePicker({
    super.key,
    required super.name,
    required this.labelText,
    required this.selectedFiles,
    required this.onFilePick,
    FormFieldValidator<List<File>>? validator,
    ValueChanged<List<File>?>? onChanged,
  }) : super(
          initialValue: selectedFiles.value,
          builder: (FormFieldState<List<File>?> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final List<File> files = await onFilePick();
                      selectedFiles.value = files;
                      field.didChange(files);
                    },
                    child: Text(labelText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: selectedFiles,
                  builder: (context, value, child) {
                    final translations = AppLocalizations.of(context)!;
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: value.isEmpty
                          ? Center(
                              child: Text(
                                  translations.no_selected(
                                      translations.photos.toLowerCase()),
                                  style:
                                      TextStyle(color: Colors.grey.shade600)))
                          : GridView.builder(
                              itemCount: value.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade200,
                                    image: DecorationImage(
                                      image: FileImage(value[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
                if (field.hasError)
                  Text(field.errorText ?? '',
                      style: const TextStyle(color: Colors.red)),
              ],
            );
          },
        );
}

class FormBuilderVideoPicker extends FormBuilderField<List<File>> {
  final String labelText;
  final ValueNotifier<List<File>> selectedVideos;
  final Future<List<File>> Function() onVideoPick;

  FormBuilderVideoPicker({
    super.key,
    required super.name,
    required this.labelText,
    required this.selectedVideos,
    required this.onVideoPick,
    FormFieldValidator<List<File>>? validator,
    ValueChanged<List<File>?>? onChanged,
  }) : super(
          initialValue: selectedVideos.value,
          builder: (FormFieldState<List<File>?> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final List<File> videos = await onVideoPick();
                      selectedVideos.value = videos;
                      field.didChange(videos);
                    },
                    child: Text(labelText,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: selectedVideos,
                  builder: (context, value, child) {
                    final translations = AppLocalizations.of(context)!;
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: value.isEmpty
                          ? Center(
                              child: Text(
                                  translations.no_selected(
                                      translations.videos.toLowerCase()),
                                  style:
                                      TextStyle(color: Colors.grey.shade600)))
                          : GridView.builder(
                              itemCount: value.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                              ),
                              itemBuilder: (context, index) {
                                return _VideoThumbnailWidget(
                                    file: value[index]);
                              },
                            ),
                    );
                  },
                ),
                if (field.hasError)
                  Text(field.errorText ?? '',
                      style: const TextStyle(color: Colors.red)),
              ],
            );
          },
        );
}

class FormBuilderOptionsPicker extends StatelessWidget {
  final String name;
  final String labelText;
  final List<Option> options;
  final ValueNotifier<int> selectedOption;
  final ValueNotifier<List<Widget>> extraFields;

  const FormBuilderOptionsPicker({
    super.key,
    required this.name,
    required this.labelText,
    required this.options,
    required this.selectedOption,
    required this.extraFields,
  });

  // Método para construir los campos dinámicos de rangos de precio
  Widget _buildPriceRangeFields(int index, AppLocalizations translations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: 'from_$index',
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
              ]),
              decoration: InputDecoration(
                  labelText: translations.from, hintText: translations.from),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              name: 'to_$index',
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
              ]),
              decoration: InputDecoration(
                  labelText: translations.to, hintText: translations.to),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              name: 'price_$index',
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
              ]),
              decoration: InputDecoration(
                  labelText: translations.price, hintText: translations.price),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              extraFields.value = List.from(extraFields.value)..removeAt(index);
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
    final TextStyle style =
        theme.textTheme.bodyLarge!.copyWith(color: Colors.black);
    return FormBuilderField<int>(
      name: name,
      initialValue: selectedOption.value,
      builder: (FormFieldState<int?> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: RadioListTile<int>(
                      shape:
                          const RoundedRectangleBorder(side: BorderSide.none),
                      contentPadding: EdgeInsets.zero,
                      title: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(options[index].text),
                      ),
                      value: options[index].value,
                      groupValue: selectedOption.value,
                      onChanged: (newValue) {
                        selectedOption.value = newValue!;
                        field.didChange(newValue);
                      },
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: selectedOption,
              builder: (context, selected, child) {
                switch (selected) {
                  case 1:
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        FormBuilderTextField(
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                          name: "fboPriceStart",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                              labelText: translations.fbo_start_price,
                              hintText: translations.fbo_start_price),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        FormBuilderTextField(
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                          name: "fboPriceEnd",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                              labelText: translations.fbo_end_price,
                              hintText: translations.fbo_end_price),
                        ),
                      ],
                    );
                  case 2:
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            onPressed: () {
                              extraFields.value = List.from(extraFields.value)
                                ..add(_buildPriceRangeFields(
                                    extraFields.value.length, translations));
                            },
                            child: Text(
                              translations
                                  .add(translations.range.toLowerCase()),
                              style: style.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: extraFields,
                          builder: (context, value, child) {
                            return Column(children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              ...value
                            ]);
                          },
                        ),
                      ],
                    );
                  default:
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        FormBuilderTextField(
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                          name: "unitPrice",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                              labelText: translations.unit_price(''),
                              hintText: translations.unit_price('')),
                        ),
                      ],
                    );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class FormBuilderCertifications extends StatelessWidget {
  final String name;
  final ValueNotifier<List<Widget>> certificationFields;

  const FormBuilderCertifications({
    super.key,
    required this.name,
    required this.certificationFields,
  });

  Widget _buildCertificationFields(int index, AppLocalizations translations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: 'certificationName_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.generic(
                    translations.certifications.split('s').first,
                    translations.name.toLowerCase()),
                hintText: translations.generic(
                    translations.certifications.split('s').first,
                    translations.name.toLowerCase()),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FormBuilderTextField(
              name: 'certificationNumber_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.number,
                hintText: translations.number,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              certificationFields.value = List.from(certificationFields.value)
                ..removeAt(index);
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
              certificationFields.value = List.from(certificationFields.value)
                ..add(_buildCertificationFields(
                    certificationFields.value.length, translations));
            },
            child: Text(
              translations.add(translations.certifications.toLowerCase()),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: certificationFields,
          builder: (context, value, child) {
            return Column(children: value);
          },
        ),
      ],
    );
  }
}

class FormBuilderSpecifications extends StatelessWidget {
  final String name;
  final ValueNotifier<List<Widget>> specificationFields;

  const FormBuilderSpecifications({
    super.key,
    required this.name,
    required this.specificationFields,
  });
  Widget _buildSpecificationFields(int index, AppLocalizations translations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: 'specificationName_$index',
              validator: FormBuilderValidators.required(),
              decoration: InputDecoration(
                labelText: translations.specification,
                hintText: translations.specification,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              specificationFields.value = List.from(specificationFields.value)
                ..removeAt(index);
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
              specificationFields.value = List.from(specificationFields.value)
                ..add(_buildSpecificationFields(
                    specificationFields.value.length,
                    AppLocalizations.of(context)!));
            },
            child: Text(
              translations.add(translations.specification.toLowerCase()),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: specificationFields,
          builder: (context, value, child) {
            return Column(children: value);
          },
        ),
      ],
    );
  }
}

class FormBuilderDetails extends StatelessWidget {
  final String name;
  final ValueNotifier<List<Map<String, String>>> detailsNotifier;

  const FormBuilderDetails({
    super.key,
    required this.name,
    required this.detailsNotifier,
  });
  Widget _buildDetailFields(int index, AppLocalizations translations) {
    return Row(
      children: [
        Expanded(
          child: FormBuilderTextField(
            name: 'detailName_$index',
            validator: FormBuilderValidators.required(),
            decoration: InputDecoration(
              labelText: translations.name,
              hintText: translations.name,
            ),
            onChanged: (value) {
              // Actualiza el detalle correspondiente
              if (detailsNotifier.value.length > index) {
                detailsNotifier.value[index]['name'] = value!;
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FormBuilderTextField(
            name: 'detailDescription_$index',
            validator: FormBuilderValidators.required(),
            decoration: InputDecoration(
              labelText: translations.description,
              hintText: translations.description,
            ),
            onChanged: (value) {
              // Actualiza la descripción correspondiente
              if (detailsNotifier.value.length > index) {
                detailsNotifier.value[index]['description'] = value!;
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            detailsNotifier.value = List.from(detailsNotifier.value)
              ..removeAt(index);
          },
        ),
      ],
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
              // final index = detailsNotifier.value.length;
              detailsNotifier.value = List.from(detailsNotifier.value)
                ..add({'name': '', 'description': ''});
              // detailsNotifier.notifyListeners();
            },
            child: Text(
              translations.add(translations.detail.toLowerCase()),
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: detailsNotifier,
          builder: (context, value, child) {
            return Column(
              children: [
                const SizedBox(height: 10.0),
                ...List.generate(
                    value.length,
                    (index) => _buildDetailFields(
                        index, AppLocalizations.of(context)!))
              ],
            );
          },
        ),
      ],
    );
  }
}
