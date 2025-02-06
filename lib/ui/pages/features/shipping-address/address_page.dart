import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

import '../../../../models/address.dart';
import '../../../../services/address-service.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  String? selectedCountryId;
  String? selectedStateId;
  String? selectedCityId;
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final AddressService _addressService = locator<AddressService>();

  String? addressError;
  String? postalCodeError;
  String? countryError;
  String? stateError;
  String? cityError;

  @override
  void initState() {
    super.initState();
    context.read<CountryBloc>().add(const AddCountriesEvent());
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['ADMIN_API_URL']}/countries?language=en'));

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final countriesData = decodedResponse['data'] as List<dynamic>;

        setState(() {
          countries = countriesData
              .map((country) => {
                    'id': country['id'],
                    'name': country['name'],
                    'flag': country['flagUrl'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> fetchStates(String countryId) async {
    try {
      final response = await http.get(Uri.parse(
          '${dotenv.env['ADMIN_API_URL']}/states?countryId=$countryId&language=en'));

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final statesData = decodedResponse['data'] as List<dynamic>;

        setState(() {
          states = statesData
              .map((state) => {'id': state['id'], 'name': state['name']})
              .toList();
          selectedStateId = null;
          selectedCityId = null;
          cities = [];
        });
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchCities(String stateId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['ADMIN_API_URL']}/cities?stateId=$stateId&language=en'),
        headers: {
          'Authorization':
              'Bearer ${locator<Preferences>().preferences['token']}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse =
            json.decode(response.body) as Map<String, dynamic>;
        final citiesData = decodedResponse['data'] as List<dynamic>;

        setState(() {
          cities = citiesData
              .map((city) => {'id': city['id'], 'name': city['name']})
              .toList();
          selectedCityId = null;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoggedUser user = context.read<UsersBloc>().state.loggedUser;
    final AppLocalizations translations = AppLocalizations.of(context)!;

    Address newAddress = Address(
        id: "",
        name: "",
        countryId: "",
        stateId: "",
        cityId: "",
        postalCode: "",
        phoneNumber: "",
        addressLine1: "",
        addressLine2: "",
        addressLine3: "",
        userId: user.userId);

    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: AppBar(title: Text(translations.add_address)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: selectedCountryId ?? translations.country,
                  decoration: InputDecoration(
                    labelText: translations.country,
                    prefixIcon: Icon(
                      Icons.map,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: translations.country,
                      child: Text(
                        translations.country,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...countries.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['id'],
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                '${dotenv.env['FLAG_URL']}${country['flag']}',
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              country['name']!.length > 12
                                  ? '${country['name']!.substring(0, 12)}...'
                                  : country['name']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    if (value != null && value != 'Country') {
                      setState(() {
                        selectedCountryId = value;
                        newAddress = newAddress.copyWith(country: value);
                      });
                      fetchStates(value);
                    }
                  },
                  validator: (value) =>
                      value == null || value == translations.country
                          ? translations.choose_country
                          : null,
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: selectedStateId,
                  decoration: InputDecoration(
                    labelText: translations.state,
                    prefixIcon: Icon(
                      Icons.maps_home_work,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        translations.state,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state['id'],
                        child: Text(
                          state['name']!.length > 12
                              ? '${state['name']!.substring(0, 12)}...'
                              : state['name']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: selectedCountryId != null
                      ? (value) {
                          setState(() {
                            selectedStateId = value;
                            newAddress =
                                newAddress.copyWith(state: value ?? '');
                          });
                          if (value != null) fetchCities(value);
                        }
                      : null,
                  validator: (value) =>
                      value == null ? translations.select_state : null,
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: selectedCityId,
                  decoration: InputDecoration(
                    labelText: translations.city,
                    prefixIcon: Icon(
                      Icons.location_city,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        translations.city,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['id'],
                        child: Text(
                          city['name']!.length > 12
                              ? '${city['name']!.substring(0, 12)}...'
                              : city['name']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: selectedStateId != null
                      ? (value) {
                          setState(() {
                            selectedCityId = value;
                            newAddress = newAddress.copyWith(city: value ?? '');
                          });
                        }
                      : null,
                  validator: (value) =>
                      value == null ? translations.select_city : null,
                ),
                const SizedBox(height: 10.0),
                FormBuilderTextField(
                  name: translations.zip_code,
                  decoration: InputDecoration(
                    labelText: translations.zip_code,
                    prefixIcon: Icon(
                      Icons.map_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) =>
                      newAddress = newAddress.copyWith(postalCode: value ?? ''),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FormBuilderTextField(
                  name: translations.phone_number,
                  decoration: InputDecoration(
                    labelText: translations.phone_number,
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => newAddress =
                      newAddress.copyWith(phoneNumber: value ?? ''),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FormBuilderTextField(
                  name: translations.address1,
                  decoration: InputDecoration(
                    labelText: translations.address1,
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => newAddress =
                      newAddress.copyWith(addressLine1: value ?? ''),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FormBuilderTextField(
                  name: translations.address2,
                  decoration: InputDecoration(
                    labelText: translations.address2,
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => newAddress =
                      newAddress.copyWith(addressLine2: value ?? ''),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FormBuilderTextField(
                  name: translations.address3,
                  decoration: InputDecoration(
                    labelText: translations.address3,
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) => newAddress =
                      newAddress.copyWith(addressLine3: value ?? ''),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                FormBuilderTextField(
                  name: translations.name,
                  decoration: InputDecoration(
                    labelText: translations.name,
                    prefixIcon: Icon(
                      Icons.home_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) =>
                      newAddress = newAddress.copyWith(name: value ?? ''),
                ),
                SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        translations.cancel,
                        style: const TextStyle(color: Color(0xff003049)),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.saveAndValidate() ?? false) {
                          setState(() {
                            savedAddress(newAddress);
                          });
                        }
                      },
                      child: Text(
                        translations.save_address,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> savedAddress(Address address) async {
    print(address.countryId = selectedCountryId!);
    print(address.cityId = selectedCityId!);
    print(address.stateId = selectedStateId!);
    final AppLocalizations translations = AppLocalizations.of(context)!;

    final String token = locator<Preferences>().preferences['refreshToken'];
    await _addressService.addAddress(address, token);
    if (_addressService.addresses.isNotEmpty) {
      setState(() {
        SuccessToast(
          title: translations.saved_address,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade500,
        ).showToast(AppRoutes.globalContext!);
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CheckoutPage()));
    } else {
      ErrorToast(
        title: translations.error,
        style: ToastificationStyle.flatColored,
        foregroundColor: Colors.white,
        backgroundColor: Colors.green.shade500,
      ).showToast(AppRoutes.globalContext!);
    }
  }
}
