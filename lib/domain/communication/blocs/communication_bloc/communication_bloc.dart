
import 'package:ourshop_ecommerce/models/models.dart';

part 'communication_event.dart';
part 'communication_state.dart';

class CommunicationBloc extends Bloc<CommunicationEvent, CommunicationState> {
  final CommunicationService _communicationService;
  CommunicationBloc(CommunicationService service) 
  : _communicationService = service,
  super(const CommunicationState()) {
    on<AddFilteredRequests>((event,emit) async {
      try {
        emit(state.copyWith(status: event.page == 1 ? CommunicationStatus.loading : CommunicationStatus.loadingmore,));
        filteredParamenters['uuids'].add({"fieldName":"company.id", "value": event.companyId });
        filteredParamenters['page'] = event.page == 0 ? 1 : event.page;
        filteredParamenters['pageSize'] = 10;
        final dynamic requests = await _communicationService.getSubmissions(filteredParamenters);
        if (requests is FilteredData<FilteredRequests>) {
          emit(state.copyWith(
             filteredRequests: List.from(state.filteredRequests)..addAll(requests.content),
             currentPage: event.page,
             hasMore: requests.page < requests.totalPages,
             status: CommunicationStatus.loaded
            )
          );
        }
      } catch (e) {
        emit(state.copyWith(status: CommunicationStatus.error));
      }
    }); 
  }
}
