import '../ui/pages/pages.dart';

class AvailableLanguages extends Equatable {
  final int id;
  final String name;
  final String countryName;
  final String flag;
  final Language language;
  final int code;

  const AvailableLanguages({
    required this.id,
    required this.name,
    required this.countryName,
    required this.flag,
    required this.language,
    required this.code,
  });

  factory AvailableLanguages.fromJson(Map<String, dynamic> json) {
    return AvailableLanguages(
      id: json['id'],
      name: json['name'],
      countryName: json['countryName'],
      flag: json['flag'],
      language: _getLanguage(json['language']),
      code: json['code'],
    );
  }


    static dynamic _getLanguage(String code) {
      switch (code) {
        case 'en':
          return Language.ENGLISH;
        case 'es':
          return Language.SPANISH;
        case 'zh':
          return Language.CHINESE;
        default:
          return code;
      }
  }


  static const List<AvailableLanguages> availableLanguages = [
    AvailableLanguages(
      id: 0,
      name: 'Spanish', 
      countryName: 'Spain',
      flag: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/800px-Flag_of_Spain.svg.png', 
      language: Language.SPANISH,
      code: 34,
    ),
    AvailableLanguages(
      id: 1,
      name: 'English',
      countryName: 'United Kingdom',
      flag: 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/800px-Flag_of_the_United_Kingdom.svg.png', 
      language: Language.ENGLISH,
      code: 44,
    ),
    AvailableLanguages(
      id: 2,
      name: 'Chinese',
      countryName: 'China',
      flag: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/800px-Flag_of_the_People%27s_Republic_of_China.svg.png',
      language: Language.CHINESE,
      code: 86,
    ),
  ];

  
  @override
  List<Object?> get props => [name, flag];
}