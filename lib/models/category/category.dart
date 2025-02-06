import '../../ui/pages/pages.dart';

class CategoryResponse {
    bool success;
    String message;
    dynamic data;

    CategoryResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory CategoryResponse.fromJson(Map<String, dynamic> json) => CategoryResponse(
        success: json["success"],
        message: json["message"],
        data: json['data'] is Map<String,dynamic> ? Category.fromJson(json['data']) : List<Category>.from(json["data"].map((x) => Category.fromJson(x))),
    );

    CategoryResponse copyWith({
        bool? success,
        String? message,
        dynamic data,
    }) => 
      CategoryResponse(
          success: success ?? this.success,
          message: message ?? this.message,
          data: data ?? this.data,
      );

    Category selectedCategory(String id) => data.firstWhere((element) => element.id == id);

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data is List<Category> ? List<dynamic>.from(data.map((x) => x.toJson())) : data.toJson(),
    };
}

class Category extends Equatable {
    final String id;
    final String name;
    final String description;
    final String? iconSvg;
    final String parentCategoryId;
    final List<Category>? subCategories;
    final int? level;
    final List<FilteredProduct> products;

    const Category({
        required this.id,
        required this.name,
        required this.description,
        this.iconSvg,
        required this.parentCategoryId,
        this.subCategories,
        this.level,
        this.products = const []
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        iconSvg: json["iconSvg"],
        parentCategoryId: json["parentCategoryId"] ?? '',
        subCategories: json["subCategories"] == null ? [] : List<Category>.from(json["subCategories"].map((x) => Category.fromJson(x))),
        level: json["level"],
    );

    Category copyWith({
        String? id,
        String? name,
        String? description,
        String? iconSvg,
        String? parentCategoryId,
        List<Category>? subCategories,
        int? level,
        List<FilteredProduct>? products,
    }) => 
      Category(
          id: id ?? this.id,
          name: name ?? this.name,
          description: description ?? this.description,
          iconSvg: iconSvg ?? this.iconSvg,
          parentCategoryId: parentCategoryId ?? this.parentCategoryId,
          subCategories: subCategories ?? this.subCategories,
          level: level ?? this.level,
          products: products ?? this.products
      );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "iconSvg": iconSvg,
        "parentCategoryId": parentCategoryId,
        "subCategories": List<dynamic>.from(subCategories!.map((x) => x.toJson())),
        "level": level,
    };
    
    @override
    
    List<Object?> get props => [
        id,
        name,
        description,
        iconSvg,
        parentCategoryId,
        subCategories,
        level,
        products
    ];
}