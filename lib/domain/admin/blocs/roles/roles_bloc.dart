import '../../../../ui/pages/pages.dart';

part 'roles_event.dart';
part 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {

  final RoleServices _roleServices;
  
  RolesBloc(RoleServices roleService) 
  : _roleServices = roleService,
  super(const RolesState()) {
    on<AddRolesEvent>((AddRolesEvent event, Emitter<RolesState> emit) async {
      try {
        emit(state.copyWith(status: RolesStatus.loading));
        final roles = await _roleServices.getRoles();
        if(roles is List<Role>){
          emit(state.copyWith(roles: roles.where((role) => role.name.toLowerCase() != 'admin' && role.name.toLowerCase() != 'business').toList(), status: RolesStatus.loaded));
        } 
      } catch (e) {
        emit(state.copyWith(status: RolesStatus.error));
      }
    });
    on<SelectedRolesEvent>((SelectedRolesEvent event, Emitter<RolesState> emit) => emit(state.copyWith(selectedRoles: event.selectedRoles)));
  }

  void addSelectedRoles(List<String> selectedRoles) => add(SelectedRolesEvent(selectedRoles));

  // Future<dynamic> getRoles() async {
  //   final roles = await _roleServices.getRoles();
  //   if(roles is List<Role>){
  //     add(AddRolesEvent(roles.where((role) => role.name.toLowerCase() != 'admin' && role.name.toLowerCase() != 'business').toList()));
  //   } 
      
  // }
}
