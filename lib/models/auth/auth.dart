
import '../../ui/pages/pages.dart';

class Authentication extends Equatable {
    final bool success;
    final String message;
    final Token data;

    const Authentication({
        required this.success,
        required this.message,
        required this.data,
    });

    factory Authentication.fromJson(Map<String, dynamic> json) => Authentication(
        success: json["success"],
        message: json["message"],
        data: Token.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
    };
    
      @override
      List<Object?> get props => [success, message, data];
}

class Token extends Equatable {
    final String token;
    final String refreshToken;

    const Token({
        required this.token,
        required this.refreshToken,
    });

    factory Token.fromJson(Map<String, dynamic> json) => Token(
        token: json["token"],
        refreshToken: json["refreshToken"],
    );


    get getTokenPayload{
      final jwt = JWT.decode(token);
      return jwt.payload;
    }



    Map<String, dynamic> toJson() => {
        "token": token,
        "refreshToken": refreshToken,
    };
    
      @override
      List<Object?> get props => [token, refreshToken];
}

class RefreshToken extends Equatable {
  final bool success;
  final String message;
  final String data;

  const RefreshToken({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) => RefreshToken(
    success: json["success"],
    message: json["message"],
    data: json["data"],
  );

  RefreshToken copyWith({
    bool? success,
    String? message,
    String? data,
  }) {
    return RefreshToken(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data,
  };
  
  @override
  List<Object?> get props => [
    success, 
    message, 
    data
  ];
}

class LoggedUser extends Equatable {
    final String userCountryName;
    final String sub;
    final String companyId;
    final String roles;
    final String companyCountryName;
    final String lastName;
    final String language;
    final String companyMainCategoryId;
    final String companyCurrentBusinessCategoryId;
    final String userPhoneNumber;
    final String companyCountryId;
    final String userId;
    final String userCountryId;
    final String companyName;
    final String name;
    final String userPhoneNumberCode;
    final int exp;
    final int iat;
    final String email;

    const LoggedUser({
        required this.sub,
        required this.userCountryName,
        required this.companyId,
        required this.roles,
        required this.companyCountryName,
        required this.lastName,
        required this.language,
        required this.companyMainCategoryId,
        required this.companyCurrentBusinessCategoryId,
        required this.userPhoneNumber,
        required this.companyCountryId,
        required this.userId,
        required this.userCountryId,
        required this.companyName,
        required this.name,
        required this.userPhoneNumberCode,
        required this.exp,
        required this.iat,
        required this.email,
    });

    factory LoggedUser.fromJson(Map<String, dynamic> json) => LoggedUser(
        userCountryName: json["user_country_name"],
        sub: json["sub"],
        companyId: json["company_id"],
        roles: json["roles"],
        companyCountryName: json["company_country_name"],
        lastName: json["last_name"],
        language: json["language"],
        companyMainCategoryId: json["company_main_category_id"],
        companyCurrentBusinessCategoryId: json["company_current_business_category_id"],
        userPhoneNumber: json["user_phone_number"],
        companyCountryId: json["company_country_id"],
        userId: json["user_id"],
        userCountryId: json["user_country_id"],
        companyName: json["company_name"],
        name: json["name"],
        userPhoneNumberCode: json["user_phone_number_code"],
        exp: json["exp"],
        iat: json["iat"],
        email: json["email"],
    );

    LoggedUser copyWith({
        String? userCountryName,
        String? sub,
        String? companyId,
        String? roles,
        String? companyCountryName,
        String? lastName,
        String? language,
        String? companyMainCategoryId,
        String? companyCurrentBusinessCategoryId,
        String? userPhoneNumber,
        String? companyCountryId,
        String? userId,
        String? userCountryId,
        String? companyName,
        String? name,
        String? userPhoneNumberCode,
        int? exp,
        int? iat,
        String? email,
    }) {
        return LoggedUser(
          sub: sub ?? this.sub,
          userCountryName: userCountryName ?? this.userCountryName,
          companyId: companyId ?? this.companyId,
          roles: roles ?? this.roles,
          companyCountryName: companyCountryName ?? this.companyCountryName,
          lastName: lastName ?? this.lastName,
          language: language ?? this.language,
          companyMainCategoryId: companyMainCategoryId ?? this.companyMainCategoryId,
          companyCurrentBusinessCategoryId: companyCurrentBusinessCategoryId ?? this.companyCurrentBusinessCategoryId,
          userPhoneNumber: userPhoneNumber ?? this.userPhoneNumber,
          companyCountryId: companyCountryId ?? this.companyCountryId,
          userId: userId ?? this.userId,
          userCountryId: userCountryId ?? this.userCountryId,
          companyName: companyName ?? this.companyName,
          name: name ?? this.name,
          userPhoneNumberCode: userPhoneNumberCode ?? this.userPhoneNumberCode,
          exp: exp ?? this.exp,
          iat: iat ?? this.iat,
          email: email ?? this.email,
        );
      }

    Map<String, dynamic> toJson() => {
        "user_country_name": userCountryName,
        "sub": sub,
        "company_id": companyId,
        "roles": roles,
        "company_country_name": companyCountryName,
        "last_name": lastName,
        "language": language,
        "company_main_category_id": companyMainCategoryId,
        "company_current_business_category_id": companyCurrentBusinessCategoryId,
        "user_phone_number": userPhoneNumber,
        "company_country_id": companyCountryId,
        "user_id": userId,
        "user_country_id": userCountryId,
        "company_name": companyName,
        "name": name,
        "user_phone_number_code": userPhoneNumberCode,
        "exp": exp,
        "iat": iat,
        "email": email,
    };
    
      @override
      List<Object?> get props => [
        userCountryName,
        sub,
        companyId,
        roles,
        companyCountryName,
        lastName,
        language,
        companyMainCategoryId,
        companyCurrentBusinessCategoryId,
        userPhoneNumber,
        companyCountryId,
        userId,
        userCountryId,
        companyName,
        name,
        userPhoneNumberCode,
        exp,
        iat,
        email,
      ];
}