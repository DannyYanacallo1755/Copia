import 'package:ourshop_ecommerce/ui/pages/pages.dart';

class ErrorHandler extends DioException{
  ErrorHandler(DioException e) : super(
    requestOptions: e.requestOptions, 
    response: e.response, 
    type: e.type, 
    error: e.error
  ){
    handleError();
  }

  void handleError() {
    final BuildContext? context = AppRoutes.globalContext;
    if (context == null) {
      return;
    }
    switch (response?.statusCode) {

      case 400:
        final error = RequestError.fromJson(response?.data);
        ErrorToast(
          title: error.message,
          description: error.message,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error, color: Colors.white,),
        ).showToast(context);
        break;
      case 401:
        final error = RequestError.fromJson(response?.data);
        ErrorToast(
          title: error.debugMessage ?? error.message,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error, color: Colors.white,),
          autoCloseDuration: const Duration(milliseconds: 1500),
          onAutoCompleted: (_) => context.go('/'),
        ).showToast(context);
        break;
      case 500:
        final error = RequestError.fromJson(response?.data);
        ErrorToast(
          title: error.debugMessage ?? error.message,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error, color: Colors.white,),
        ).showToast(context);
        break;
      default:
        final error = RequestError.fromJson(response?.data);
        ErrorToast(
          title: error.debugMessage ?? error.message,
          description: error.message,
          style: ToastificationStyle.flatColored,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red.shade500,
          icon: const Icon(Icons.error, color: Colors.white,),
        ).showToast(context);
    }
  }
}


class RequestError extends Equatable {
    final bool success;
    final String message;
    final dynamic data;
    final dynamic debugMessage;

    const RequestError({
        required this.success,
        required this.message,
        required this.data,
        required this.debugMessage,
    });

    factory RequestError.fromJson(Map<String, dynamic> json) => RequestError(
        success: json["success"],
        message: json["message"],
        data: json["data"],
        debugMessage: json["debugMessage"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
        "debugMessage": debugMessage,
    };
    
      @override
      List<Object?> get props => [success, message, data, debugMessage];
}