part of 'country_bloc.dart';

sealed class CountryEvent extends Equatable {
  const CountryEvent();

  @override
  List<Object> get props => [];
}

class AddCountriesEvent extends CountryEvent {
  const AddCountriesEvent();

  @override
  List<Object> get props => [];
}
