
import '../../ui/pages/pages.dart';

class RoleResponse extends Equatable {
    final bool success;
    final String message;
    final List<Role> data;

    const RoleResponse({
        required this.success,
        required this.message,
        required this.data,
    });

    factory RoleResponse.fromJson(Map<String, dynamic> json) => RoleResponse(
        success: json["success"],
        message: json["message"],
        data: List<Role>.from(json["data"].map((x) => Role.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
    
    @override
    List<Object?> get props => [success, message, data];
}

class Role extends Equatable {
    final String id;
    final String name;

    const Role({
        required this.id,
        required this.name,
    });

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
    
    @override
    List<Object?> get props => [id, name];
}