import '../../ui/pages/pages.dart';

class SocialMediaResponse {
    final bool success;
    final String message;
    final List<SocialMedia> data;

    SocialMediaResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    SocialMediaResponse copyWith({
        bool? success,
        String? message,
        List<SocialMedia>? data,
    }) => 
        SocialMediaResponse(
            success: success ?? this.success,
            message: message ?? this.message,
            data: data ?? this.data,
        );

    factory SocialMediaResponse.fromJson(Map<String, dynamic> json) => SocialMediaResponse(
        success: json["success"],
        message: json["message"],
        data: List<SocialMedia>.from(json["data"].map((x) => SocialMedia.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class SocialMedia extends Equatable {
    final String id;
    final String name;

    const SocialMedia({
        required this.id,
        required this.name,
    });

    SocialMedia copyWith({
        String? id,
        String? name,
    }) => 
        SocialMedia(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
    
    @override
    List<Object?> get props => [
        id,
        name,
    ];
}