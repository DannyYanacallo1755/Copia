part of 'roles_bloc.dart';

sealed class RolesEvent extends Equatable {
  const RolesEvent();

  @override
  List<Object> get props => [];
}

class AddRolesEvent extends RolesEvent {

  const AddRolesEvent();

  @override
  List<Object> get props => [];
}

class SelectedRolesEvent extends RolesEvent {
  final List<String> selectedRoles;
  const SelectedRolesEvent(this.selectedRoles);

  @override
  List<Object> get props => [selectedRoles];
}
