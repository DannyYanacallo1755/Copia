part of 'communication_bloc.dart';

enum CommunicationStatus { initial, loading, loaded, error, loadingmore }

class CommunicationState extends Equatable {

  final List<FilteredRequests> filteredRequests;
  final CommunicationStatus status;
  final int currentPage;
  final bool hasMore;

  const CommunicationState({
    this.filteredRequests = const [],
    this.status = CommunicationStatus.initial,
    this.currentPage = 0,
    this.hasMore = false,
  });

  CommunicationState copyWith({
    List<FilteredRequests>? filteredRequests,
    CommunicationStatus? status,
    int? currentPage,
    bool? hasMore,
  }) {
    return CommunicationState(
      filteredRequests: filteredRequests ?? this.filteredRequests,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
  
  @override
  List<Object> get props => [
    filteredRequests,
    status,
    currentPage,
    hasMore,
  ];
}
