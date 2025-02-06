import 'dart:async';
import 'package:ourshop_ecommerce/ui/pages/pages.dart';

part 'general_event.dart';
part 'general_state.dart';

class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  StreamSubscription? _subscription;
  GeneralBloc() : super(const GeneralState()) {
    _subscription = _monitorConnectivity().listen((isConnected) {
      add(InternetConnectionChangedEvent(isConnected));
    });
    on<AddIsLoadingEvent>((event, emit) => emit(state.copyWith(isLoading: event.isLoading)));
    on<ChangeBottomNavTab>((event, emit) => emit(state.copyWith(selectedBottomNavTab: event.index)));
    on<InternetConnectionChangedEvent>((event, emit) => emit(state.copyWith(isInterentConnectionActive: event.interNetConnectionActive)));
    on<KeyboardVisibilityChangedEvent>((event, emit) => emit(state.copyWith(keyboardVisible: event.keyboardVisible)));
  }

   @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Stream<bool> _monitorConnectivity() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield await _hasInternetConnection();
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
