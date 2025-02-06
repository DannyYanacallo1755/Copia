part of 'general_bloc.dart';

sealed class GeneralEvent extends Equatable {
  const GeneralEvent();

  @override
  List<Object> get props => [];
}

class AddIsLoadingEvent extends GeneralEvent {
  final bool isLoading;
  const AddIsLoadingEvent(this.isLoading);
  @override
  List<Object> get props => [isLoading];
}

class ChangeBottomNavTab extends GeneralEvent {
  final int index;

  const ChangeBottomNavTab(this.index);

  @override
  List<Object> get props => [index];
}

class InternetConnectionChangedEvent extends GeneralEvent {
  final bool interNetConnectionActive;
  const InternetConnectionChangedEvent(this.interNetConnectionActive);

  @override
  List<Object> get props => [interNetConnectionActive];
}

class KeyboardVisibilityChangedEvent extends GeneralEvent {
  final bool keyboardVisible;
  const KeyboardVisibilityChangedEvent({required this.keyboardVisible});

  @override
  List<Object> get props => [keyboardVisible];
}
