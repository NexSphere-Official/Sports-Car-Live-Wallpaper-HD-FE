import 'package:flutter/material.dart';

class AppNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  Future<R?> push<R>(Route<R> route, {bool useRoot = false}) async =>
      _navigator(useRoot: useRoot).push(route);

  Future<R?> pushReplacement<R>(
    Route<R> route, {
    bool useRoot = false,
    R? result,
  }) async =>
      _navigator(useRoot: useRoot).pushReplacement(route, result: result);

  void close() => closeWithResult(null);
  void closeWithResult<T>(T result) => _navigator().pop(result);
  void popUntilRoot() => _navigator().popUntil((route) => route.isFirst);
}

Route<T> materialRoute<T>(Widget page, {bool fullScreenDialog = false}) =>
    MaterialPageRoute(
      builder: (context) => page,
      fullscreenDialog: fullScreenDialog,
    );

Route<T> fadeInRoute<T>(Widget page, {int? durationMillis}) =>
    PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: durationMillis ?? 250),
      pageBuilder: (context, animation, _) =>
          FadeTransition(opacity: animation, child: page),
    );

Route<T> slideBottomRoute<T>(
  Widget page, {
  int? durationMillis,
  bool fullScreenDialog = false,
}) => PageRouteBuilder<T>(
  transitionDuration: Duration(milliseconds: durationMillis ?? 250),
  fullscreenDialog: fullScreenDialog,
  pageBuilder: (context, animation, _) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuint)),
    child: page,
  ),
);

Route<T> bottomSheetRoute<T>(Widget page) => ModalBottomSheetRoute(
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: page,
  ),
  isScrollControlled: true,
  useSafeArea: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
  ),
);

NavigatorState _navigator({bool useRoot = false}) =>
    AppNavigator.navigatorKey.currentState!;
