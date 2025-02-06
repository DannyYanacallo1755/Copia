import 'dart:convert';
import 'dart:developer';

import '../../../../../pages.dart';

class NewAdminProduct extends StatefulWidget {
  const NewAdminProduct({super.key});

  @override
  State<NewAdminProduct> createState() => _NewAdminProductState();
}

class _NewAdminProductState extends State<NewAdminProduct> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add( AddSubCategoriesNewProductEvent(
        categoryId: context.read<UsersBloc>().state.loggedUser.companyMainCategoryId
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations translations = AppLocalizations.of(context)!;
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: state.productsStates == ProductsStates.adding ? null : () => context.pop(context),
            ),
            title:  Text(translations.new_product),
          ),
          body: state.productsStates == ProductsStates.adding ?
          const Center(child:  CircularProgressIndicator.adaptive()) 
          : ProductForm(
            formKey: _formKey,
            mode: AdminProductMode.NEW,
            
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: state.productsStates == ProductsStates.adding ? null : () async  {
              try {  
                if (_formKey.currentState!.saveAndValidate()) {
                  final Map<String, dynamic> values = _formKey.currentState!.value;
                  final Map<String ,dynamic> data = prepareDataForBackend(values);
                  final FormData form = await createFormData(data);
                  locator<ProductsBloc>().add(AddNewProductEvent(form: form));
                  // logFormData(form);
                }
              } catch (e) {
                log('Exception: $e');
              }
            },
            child: state.productsStates == ProductsStates.adding ? CircularProgressIndicator.adaptive(backgroundColor: AppTheme.palette[550],) :  const Icon(Icons.save, color: Colors.white,),
          ),
        );
      },
    );
  }

  Future<void> logFormData(FormData formData) async {
    // Imprime los campos del FormData
    for (MapEntry<String, String> field in formData.fields) {
      log('Campo: ${field.key}, Valor: ${field.value}');
    }

    // Imprime los archivos del FormData
    for (MapEntry<String, MultipartFile> file in formData.files) {
      log('Archivo: ${file.key}, Nombre: ${file.value.filename}, Tamaño: ${file.value.length}');
    }
  }

  Map<String, dynamic> prepareDataForBackend(Map<String, dynamic> formData) {
    
    // Transformar los detalles
    List<Map<String, String>> details = [];
    formData.forEach((key, value) {
      if (key.startsWith('detailName_')) {
        final index = key.split('_').last;
        details.add({
          'name': value,
          'description': formData['detailDescription_$index'],
        });
      }
    });

    // Transformar las especificaciones
    List<Map<String, String>> specifications = [];
    formData.forEach((key, value) {
      if (key.startsWith('specificationName_')) {
        specifications.add({'name': value});
      }
    });

    // Transformar las certificaciones
    List<Map<String, String>> certifications = [];
    formData.forEach((key, value) {
      if (key.startsWith('certificationName_')) {
        final index = key.split('_').last;
        certifications.add({
          'name': value,
          'certificationNumber': formData['certificationNumber_$index'],
        });
      }
    });

    //Transformar los campos priceByQuantity
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

    //Crear el objeto final que enviarás al backend
    final Map<String, dynamic> data = {
      'name': formData['name'],
      'keyValue': formData['keyValue'],
      'productGroupId': formData['productGroupId'],
      'categoryId': formData['categoryId'],
      'modelNumber': formData['modelNumber'],
      'productTypeId': formData['productTypeId'],
      'brandName': formData['brandName'],
      'unitMeasurementId': formData['unitMeasurementId'],
      'unitPrice': formData['unitPrice'],
      'fboPriceStart': formData['fboPriceStart'],
      'fboPriceEnd': formData['fboPriceEnd'],
      'usePriceRange': formData['priceOptions'] == 2,
      'stock': formData['stock'],
      'packageLength': formData['packageLength'],
      'packageWidth': formData['packageWidth'],
      'packageHeight': formData['packageHeight'],
      'packageWeight': formData['packageWeight'],
      'details': details,
      'specifications': specifications,
      'certifications': certifications,
      'priceByQuantity': priceByQuantity,
      'photos': formData['photos'],
      'videos': formData['videos'],
      'priceType': formData['priceType'],
    };

    return data;
  }
  Future<FormData> createFormData(Map<String, dynamic> formData) async {
    FormData formDataObj = FormData();

    List<Map<String, dynamic>> priceByQuantity = [];
    if (formData['priceOptions'] == 2 && formData['priceByQuantity'] != null) {
      priceByQuantity = List<Map<String, dynamic>>.from(formData['priceByQuantity']);
    }

    // Agregar los datos del producto
    final Map<String, dynamic> productData = {
      'name': formData['name'],
      'keyValue': formData['keyValue'],
      'productGroupId': formData['productGroupId'],
      'categoryId': formData['categoryId'],
      'modelNumber': formData['modelNumber'],
      'productTypeId': formData['productTypeId'],
      'brandName': formData['brandName'],
      'unitMeasurementId': formData['unitMeasurementId'],
      'unitPrice': formData['unitPrice'],
      'fboPriceStart': formData['fboPriceStart'],
      'fboPriceEnd': formData['fboPriceEnd'],
      'usePriceRange': formData['priceOptions'] == 2, 
      'moqUnit': formData['moqUnit'] ?? '',
      'stock': formData['stock'],
      'packageLength': formData['packageLength'],
      'packageWidth': formData['packageWidth'],
      'packageHeight': formData['packageHeight'],
      'packageWeight': formData['packageWeight'],
      'details': formData['details'] ?? [], 
      'specifications': formData['specifications'] ?? [], 
      'certifications': formData['certifications'] ?? [], 
      'priceByQuantity': priceByQuantity,  // Agregar los rangos de precios dentro del producto
      'priceType': formData['priceType'],
      'photos': formData['photos'] != null ? [] : [],
      'videos': formData['videos'] != null ? [] : [],
      'dataSheetDeleted': false, 
      'priceRanges': formData['priceRanges'] ?? [],
    };
    //add product data to form data
    formDataObj.fields.add(MapEntry('product', jsonEncode(productData)));

    //Add the photos files
    if (formData['photos'] != null && formData['photos'].isNotEmpty) {
      for (var file in formData['photos']) {
        formDataObj.files.add(MapEntry(
          'newPhotos', 
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
    }

    //Add the videos files
    if (formData['videos'] != null && formData['videos'].isNotEmpty) {
      for (var file in formData['videos']) {
        formDataObj.files.add(MapEntry(
          'newVideos', 
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }
    }

    return formDataObj;
  }
}