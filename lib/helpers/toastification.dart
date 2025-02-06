import 'dart:developer';

import '../ui/pages/pages.dart';

sealed class Toast {
  showToast(BuildContext context);
}

class SuccessToast extends Toast {
  final String title;
  final ToastificationStyle? style;
  final TextStyle? titleStyle;
  final Duration? autoCloseDuration;
  final String? description;
  final Alignment? alignment;
  final TextDirection? direction;
  final bool? showProgressBar;
  final ProgressIndicatorThemeData? progressBarTheme;
  final CloseButtonShowType? closeButtonShowType;
  final bool? closeOnClick;
  final bool? pauseOnHover;
  final bool? dragToClose;
  final bool? applyBlurEffect;
  final Widget? icon;
  final bool? showIcon;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Function(ToastificationItem)? onAutoCompleted;

  SuccessToast({
    required this.title,
    this.style,
    this.titleStyle,
    this.autoCloseDuration,
    this.description,
    this.alignment,
    this.direction,
    this.showProgressBar,
    this.progressBarTheme,
    this.closeButtonShowType,
    this.closeOnClick,
    this.pauseOnHover,
    this.dragToClose,
    this.applyBlurEffect,
    this.icon,
    this.showIcon,
    this.primaryColor,
    this.backgroundColor,
    this.foregroundColor,
    this.onAutoCompleted,
  });

  @override
  showToast(BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: style ?? ToastificationStyle.flat,
      autoCloseDuration: autoCloseDuration ?? const Duration(seconds: 5),
      title: Text(
        title,
        style: titleStyle,
      ),
      description: RichText(text: TextSpan(text: description ?? '')),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: icon ?? const Icon(Icons.check),
      showIcon: showIcon ?? false,
      primaryColor: primaryColor ?? Colors.green,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: showProgressBar ?? true,
      progressBarTheme: progressBarTheme,
      closeButtonShowType: closeButtonShowType ?? CloseButtonShowType.onHover,
      closeOnClick: closeOnClick ?? false,
      pauseOnHover: pauseOnHover ?? true,
      dragToClose: dragToClose ?? true,
      applyBlurEffect: applyBlurEffect ?? false,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
        onCloseButtonTap: (toastItem) =>
            log('Toast ${toastItem.id} close button tapped'),
        onAutoCompleteCompleted: (toastItem) =>
            onAutoCompleted != null ? onAutoCompleted!(toastItem) : null,
        onDismissed: (toastItem) => log('Toast ${toastItem.id} dismissed'),
      ),
    );
  }
}

class ErrorToast extends Toast {
  final String title;
  final ToastificationStyle? style;
  final TextStyle? titleStyle;
  final Duration? autoCloseDuration;
  final String? description;
  final Alignment? alignment;
  final TextDirection? direction;
  final bool? showProgressBar;
  final ProgressIndicatorThemeData? progressBarTheme;
  final CloseButtonShowType? closeButtonShowType;
  final bool? closeOnClick;
  final bool? pauseOnHover;
  final bool? dragToClose;
  final bool? applyBlurEffect;
  final Widget? icon;
  final bool? showIcon;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Function(ToastificationItem)? onAutoCompleted;

  ErrorToast({
    required this.title,
    this.style,
    this.titleStyle,
    this.autoCloseDuration,
    this.description,
    this.alignment,
    this.direction,
    this.showProgressBar,
    this.progressBarTheme,
    this.closeButtonShowType,
    this.closeOnClick,
    this.pauseOnHover,
    this.dragToClose,
    this.applyBlurEffect,
    this.icon,
    this.showIcon,
    this.primaryColor,
    this.backgroundColor,
    this.foregroundColor,
    this.onAutoCompleted,
  });

  @override
  showToast(BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: style ?? ToastificationStyle.flat,
      autoCloseDuration: autoCloseDuration ?? const Duration(seconds: 5),
      title: Text(
        title,
        style: titleStyle,
      ),
      description: RichText(text: TextSpan(text: description ?? '')),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 200),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      icon: icon ?? const Icon(Icons.check),
      showIcon: showIcon ?? false,
      primaryColor: primaryColor ?? Colors.red.shade200,
      backgroundColor: backgroundColor ?? Colors.red,
      foregroundColor: foregroundColor ?? Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        )
      ],
      showProgressBar: showProgressBar ?? true,
      progressBarTheme: progressBarTheme,
      closeButtonShowType: closeButtonShowType ?? CloseButtonShowType.onHover,
      closeOnClick: closeOnClick ?? false,
      pauseOnHover: pauseOnHover ?? true,
      dragToClose: dragToClose ?? true,
      applyBlurEffect: applyBlurEffect ?? false,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
        onCloseButtonTap: (toastItem) =>
            log('Toast ${toastItem.id} close button tapped'),
        onAutoCompleteCompleted: (toastItem) =>
            onAutoCompleted != null ? onAutoCompleted!(toastItem) : null,
        onDismissed: (toastItem) => log('Toast ${toastItem.id} dismissed'),
      ),
    );
  }
}
