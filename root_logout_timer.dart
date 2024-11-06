import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logout_timer_cubit.dart';

enum LogoutTime {
  oneMinute(Duration(minutes: 1), "1 minute"),
  tenMinutes(Duration(minutes: 10), "10 minutes"),
  fifteenMinutes(Duration(minutes: 15), "15 minutes"),
  thirtyMinutes(Duration(minutes: 30), "30 minutes"),
  fortyFiveMinutes(Duration(minutes: 45), "45 minutes"),
  hour(Duration(hours: 1), "1 hour"),
  twoHours(Duration(hours: 2), "2 hours");

  final Duration duration;
  final String title;

  const LogoutTime(this.duration, this.title);
}

///Steps to use.
/// 1. Use as _YourWidgetState extends State<YourWidget> with [AutoLogoutTimerMixin] with [AutoLogoutTimerMixin].
///
/// 2. [override] required methods.
///
/// 3. override [logoutTime] as:
///      @override
///      [Duration] get [logoutTime] => YOUR_LOGOUT_DURATION;
///
/// 4. override [onTimerExceeded] as:
///      @override
///      VoidCallback get onTimerExceeded => () {Task to be done when logout timer exceeded}; eg. Push to login screen.
///
/// 5. Remove [build] method instead use [buildChild].
///      Hence, just do this.
///      @override
///      Widget build(BuildContext context) -> Widget buildChild(BuildContext context)
///
/// 6. override [globalNavigatorKey] as:
///    @override
///    GlobalKey<NavigatorState> get globalNavigatorKey => MATERIAL_APP_NAVIGATOR_KEY;
///    eg,
///    MaterialApp(
///        navigatorKey: NAVIGATOR_KEY, <- [This]
///      );
///
/// 7. Use [BlocProvider].of<[AutoLogoutTimerCubit]>([context]).initiateTimer() to start [AutoLogoutTimerMixin]; eg. After Login.
///
/// 8. Use [BlocProvider].of<[AutoLogoutTimerCubit]>([context]).endTimer() to stop [AutoLogoutTimerMixin]; eg. After Logout.

mixin AutoLogoutTimerMixin<T extends StatefulWidget> on State<T>
    implements WidgetsBindingObserver {
  ///(Private variable): Used to handle logout timer.
  late final AutoLogoutTimerCubit _logoutTimerCubit;

  ///(Required): Set [logoutTime] to set Auto logout [Duration].
  Duration get logoutTime;

  ///(Required): Use [onTimerExceeded] Callback for timer exceeded the auto logout time.
  VoidCallback get onTimerExceeded;

  ///(Required): [GlobalKey] to show dialog on global context. (The one which you assign to MaterialApp)
  GlobalKey<NavigatorState> get globalNavigatorKey;

  ///(Required): Use [countDownWidgetBuilder] return a [Widget] you need to show on last ten seconds;
  ///If not overridden It will return [TimerExceededWidget].
  Widget countDownWidgetBuilder(int countDownTick, BuildContext context);

  ///(Required): Remove [build] method overridden from [StatefulWidget] instead use this [buildChild] method.
  Widget buildChild(BuildContext context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logoutTimerCubit = AutoLogoutTimerCubit(countDownWidgetBuilder,
        logoutTime.inSeconds, onTimerExceeded, globalNavigatorKey);
  }

  @override
  void dispose() {
    _logoutTimerCubit.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///To handle life cycle states
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        _logoutTimerCubit.onResume();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        _logoutTimerCubit.onPaused();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _logoutTimerCubit,
      child: BlocConsumer(
        bloc: _logoutTimerCubit,
        listener: (context, LogoutTimerState state) {
          if (state is LogoutTimerStart) {
            _logoutTimerCubit.startLogoutTimer();
          } else if (state is LogoutTimerEnd) {
            _logoutTimerCubit.stopTimer();
          }
        },
        builder: (context, state) {
          return (kIsWeb)
              ? MouseRegion(
                  onHover: (state is LogoutTimerStart)
                      ? (_) => _logoutTimerCubit.resetTimer()
                      : null,
                  child: buildChild(context))
              : Listener(
                  onPointerDown: (_) {
                    (_logoutTimerCubit.timer != null)
                        ? _logoutTimerCubit.stopTimer()
                        : null;
                  },
                  onPointerUp: (_logoutTimerCubit.state is LogoutTimerStart &&
                          !_logoutTimerCubit.countDownBegan)
                      ? (_) {
                          if (_logoutTimerCubit.timer == null) {
                            _logoutTimerCubit.initiateTimer();
                          }
                        }
                      : null,
                  child: buildChild(context),
                );
        },
      ),
    );
  }

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didChangeAccessibilityFeatures() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didChangeLocales(List<Locale>? locales) {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didChangeMetrics() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didChangePlatformBrightness() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didChangeTextScaleFactor() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void didHaveMemoryPressure() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  Future<bool> didPopRoute() async => false;

  ///Overridden from [WidgetsBindingObserver]
  @override
  Future<bool> didPushRoute(String route) async => false;

  ///Overridden from [WidgetsBindingObserver]
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    final Uri uri = routeInformation.uri;
    return didPushRoute(
      Uri.decodeComponent(
        Uri(
          path: uri.path.isEmpty ? '/' : uri.path,
          queryParameters:
              uri.queryParametersAll.isEmpty ? null : uri.queryParametersAll,
          fragment: uri.fragment.isEmpty ? null : uri.fragment,
        ).toString(),
      ),
    );
  }

  ///Overridden from [WidgetsBindingObserver]
  @override
  Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.exit;

  ///Overridden from [WidgetsBindingObserver]
  @override
  void handleCancelBackGesture() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  void handleCommitBackGesture() {}

  ///Overridden from [WidgetsBindingObserver]
  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) => false;

  ///Overridden from [WidgetsBindingObserver]
  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}
