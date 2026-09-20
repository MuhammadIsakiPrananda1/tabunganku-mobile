import 'package:flutter/material.dart';

/// Helper global untuk menampilkan bottom sheet yang otomatis
/// menyesuaikan diri dengan sistem navigasi HP (gesture / 3 tombol bulat).
///
/// Gunakan [showAppBottomSheet] sebagai pengganti [showModalBottomSheet]
/// agar konten tidak tertutup tombol sistem di HP manapun.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color backgroundColor = Colors.transparent,
  ShapeBorder? shape,
  double? elevation,
  Clip clipBehavior = Clip.none,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    // useSafeArea: true → bottom sheet otomatis naik
    // di atas tombol sistem (gesture / 3-button navigation)
    useSafeArea: true,
    shape: shape,
    elevation: elevation,
    clipBehavior: clipBehavior,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    useRootNavigator: useRootNavigator,
  );
}

/// Extension pada BuildContext untuk kemudahan pemanggilan.
/// Contoh: context.showAppSheet(builder: (ctx) => MySheet())
extension AppBottomSheetExtension on BuildContext {
  Future<T?> showAppSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color backgroundColor = Colors.transparent,
    ShapeBorder? shape,
    bool useRootNavigator = false,
  }) {
    return showAppBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      shape: shape,
      useRootNavigator: useRootNavigator,
    );
  }
}
