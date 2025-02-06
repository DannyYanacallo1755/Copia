part of 'country_bloc.dart';

enum CountryStatus { initial, loading, loaded, error }

class CountryState extends Equatable {

  final List<Country> countries;
  final CountryStatus status;
  const CountryState({
    this.countries = const [],
    this.status = CountryStatus.initial,
  });

  CountryState copyWith({
    List<Country>? countries,
    CountryStatus? status,
  }) {
    return CountryState(
      countries: countries ?? this.countries,
      status: status ?? this.status,
    );
  }

  Country getCountryById(String id) {
    return countries.firstWhere(
      (country) => country.id == id, 
      orElse: () {
        return countries.isNotEmpty
        ? countries.first
        : const Country(id: '', name: '', iso: '', iso3: '', numCode: 0, phoneCode: 0, flagUrl: '');
      },
    );
  }
  
  @override
  List<Object> get props => [countries, status];
}
