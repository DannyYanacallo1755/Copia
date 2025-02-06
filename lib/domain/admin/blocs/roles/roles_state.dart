part of 'roles_bloc.dart';

enum RolesStatus { initial, loading, loaded, error }

class RolesState extends Equatable {

  final List<Role> roles;
  final List<String> selectedRoles;
  final RolesStatus status;
  const RolesState({
    this.roles = const [],
    this.selectedRoles = const [],
    this.status = RolesStatus.initial,
  });

  RolesState copyWith({
    List<Role>? roles,
    List<String>? selectedRoles,
    RolesStatus? status,
  }) {
    return RolesState(
      roles: roles ?? this.roles,
      selectedRoles: selectedRoles ?? this.selectedRoles,
      status: status ?? this.status,
    );
  }

  Role get sellerRole => roles.firstWhere((role) => role.name.toLowerCase() == 'seller');

  @override
  List<Object> get props => [roles, selectedRoles, status];
}
