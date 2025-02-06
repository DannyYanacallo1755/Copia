part of 'general_bloc.dart';

class GeneralState extends Equatable {

  final bool isLoading;
  final int selectedBottomNavTab;
  final bool isInterentConnectionActive;
  final bool keyboardVisible;

  const GeneralState({
    this.isLoading = false,
    this.selectedBottomNavTab = 0,
    this.isInterentConnectionActive = true,
    this.keyboardVisible = false,
  });

  GeneralState copyWith({
    bool? isLoading,
    int? selectedBottomNavTab,
    bool? isInterentConnectionActive,
    bool? keyboardVisible,
  }) => GeneralState(
    selectedBottomNavTab: selectedBottomNavTab ?? this.selectedBottomNavTab,
    isInterentConnectionActive: isInterentConnectionActive ?? this.isInterentConnectionActive,
    keyboardVisible: keyboardVisible ?? this.keyboardVisible,
  );
  
  @override
  List<Object> get props => [isLoading ,selectedBottomNavTab, isInterentConnectionActive, keyboardVisible];
}
