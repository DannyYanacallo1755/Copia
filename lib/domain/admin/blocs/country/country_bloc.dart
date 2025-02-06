import 'dart:developer';

import '../../../../ui/pages/pages.dart';

part 'country_event.dart';
part 'country_state.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {

  final CountryService _countryService;
  
  CountryBloc(CountryService countryService) : _countryService = countryService, 
  super(const CountryState()) {
    on<AddCountriesEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: CountryStatus.loading));
        final countries = await _countryService.getCountries();
        if (countries is List<Country>) {
          emit(state.copyWith(countries: countries, status: CountryStatus.loaded));
        }
      } catch (e) {
        log('Error: $e');
        emit(state.copyWith(status: CountryStatus.error));
      }
    });
  }
}
