


import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_map/ui/common/app_colors.dart';
import 'package:google_map/ui/common/ui_helpers.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:velocity_x/velocity_x.dart';

class EasyLoadingService {
  bool isLoaderAlreadyShowing = false;
  final GlobalKey<NavigatorState>? navigatorKey = StackedService.navigatorKey;

  BuildContext? get getContext => navigatorKey?.currentContext;

  EasyLoadingService() {
    setupCustomLoader();
  }
  setupCustomLoader() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..dismissOnTap = false
      ..toastPosition = EasyLoadingToastPosition.bottom
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.white
      ..progressColor = Colors.transparent
      ..textColor = kcPrimaryColor
      ..maskColor = Colors.transparent
      ..maskType = EasyLoadingMaskType.custom
      ..indicatorColor = kcPrimaryColor
      ..customAnimation = CustomAnimation();
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.show) {
        isLoaderAlreadyShowing = true;
      } else {
        isLoaderAlreadyShowing = false;
      }
    });
  }

  showLoader(String text) {
    if (!isLoaderAlreadyShowing) {
      EasyLoading.show(status: text);
    }
  }

  showSuccessToast({String? title}) {
    BuildContext? context = getContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        elevation: 0,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: VxBox(
                child: HStack(
          [
            hSpace(10),
            (title ?? "Success").text.sm.white.make().expand(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: "Ok".text.sm.uppercase.semiBold.white.make(),
            ),
          ],
          crossAlignment: CrossAxisAlignment.center,
        ).p(15))
            .withRounded(value: secondaryRadius)
            .black
            .make(),
      ));
    }
  }

  showErrorToast({
    String? title,
    String? description,
  }) {
    BuildContext? context = getContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        elevation: 0,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: VxBox(
                child: HStack([
          hSpace(10),
          Expanded(
            child: VStack(
              [
                (title ?? "Error").text.sm.white.make(),
                if (description != null) (description).text.xs.white.make(),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: "Ok".text.sm.uppercase.semiBold.white.make(),
          ),
        ]).p(15))
            .withRounded(value: secondaryRadius)
            .black
            .make(),
      ));
    }
  }

  showSuccessDialog(String text) {
    EasyLoading.showSuccess(text);
  }

  showErrorDialog(String text) {
    EasyLoading.showError(text);
  }

  removeLoader() {
    EasyLoading.dismiss(animation: true);
  }
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
    Widget child,
    AnimationController controller,
    AlignmentGeometry alignment,
  ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}