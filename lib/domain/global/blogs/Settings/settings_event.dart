part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}


class ChangeLanguage extends SettingsEvent {
  final Language language;
  const ChangeLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class ChangeTheme extends SettingsEvent {
  final ThemeMode theme;
  const ChangeTheme(this.theme);

  @override
  List<Object> get props => [theme];
}

class ChangeSelectedLanguage extends SettingsEvent {
  final int selectedLanguage;
  const ChangeSelectedLanguage({required this.selectedLanguage});

  @override
  List<Object> get props => [selectedLanguage];
}
