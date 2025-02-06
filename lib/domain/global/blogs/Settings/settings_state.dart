part of 'settings_bloc.dart';



class SettingsState extends Equatable {

  final Language currentLanguage;
  final ThemeMode currentTheme;
  final int selectedLanguage;
  final bool disable;

  const SettingsState({
    this.currentLanguage = Language.ENGLISH,
    this.currentTheme = ThemeMode.light,
    this.selectedLanguage = -1,
    this.disable = true,
  });

  SettingsState copyWith({
    Language? currentLanguage,
    ThemeMode? currentTheme,
    int? selectedLanguage,
    bool? disable,
  }) => SettingsState(
    currentLanguage: currentLanguage ?? this.currentLanguage,
    currentTheme: currentTheme ?? this.currentTheme,
    selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    disable: disable ?? this.disable,
  );


  
  @override
  List<Object> get props => [
    currentLanguage, 
    currentTheme, 
    selectedLanguage, 
    disable
  ];

  get isNextButtonEnabled => null;
}

