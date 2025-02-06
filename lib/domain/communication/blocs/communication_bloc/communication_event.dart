part of 'communication_bloc.dart';

sealed class CommunicationEvent extends Equatable {
  const CommunicationEvent();

  @override
  List<Object> get props => [];
}


class AddFilteredRequests extends CommunicationEvent {
  final int page;
  final String companyId;
  const AddFilteredRequests({required this.page, required this.companyId});

  @override
  List<Object> get props => [page, companyId];
}
