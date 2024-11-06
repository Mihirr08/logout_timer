import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'update_counter_cubit.dart';

part 'logout_timer_state.dart';

class AutoLogoutTimerCubit extends Cubit<LogoutTimerState> {
  AutoLogoutTimerCubit(
      this.countDownWidgetBuilder, this.logoutTime, this.onTimerExceeded, this.globalNavigatorKey)
      : super(LogoutTimerInitial());


  final Widget Function(int countDownTick, BuildContext context)
      countDownWidgetBuilder;

  ///Inactivity logout time
  int logoutTime;

  ///Global Navigator key
  final GlobalKey<NavigatorState>? globalNavigatorKey;

  ///Function to be called when timer exceed
  final void Function() onTimerExceeded;

  ///Timer
  Timer? timer;

  ///Timer tick
  int? _idleTimerTick;

  final DialogActivityCubit _dialogActivityCubit = DialogActivityCubit();

  ///Count down buffer
  final int _countDownBuffer = 10;

  ///Boolean to determine whether dialog is shown or not
  bool _dialogShown = false;

  ///To store background date time
  DateTime? _bgDateTime;

  @override
  Future<void> close() async {
    super.close();
    timer?.cancel();
    timer = null;
    _dialogActivityCubit.close();
  }

  ///Start timer
  void initiateTimer() {
    emit(LogoutTimerStart());
    // startLogoutTimer();
  }

  ///Set auto logout timer
  void setAutoLogoutTime(Duration time) {
    emit(LogoutTimerEnd());
    logoutTime = time.inSeconds;
    emit(LogoutTimerStart());
  }

  ///End timer
  void endTimer() {
    emit(LogoutTimerEnd());
    stopTimer();
  }

  void _printLog(String text) {
    // if (kDebugMode) debugPrint("[RootLogoutTimer]: $text");
  }

  ///Function to start idle timer
  void startLogoutTimer() {
    if (_idleTimerTick != null) {
      stopTimer();
    }

    //Timer
    timer = Timer.periodic(const Duration(seconds: 1), (final timer) {
      try {
        _idleTimerTick ??= 0;

        _idleTimerTick = _idleTimerTick! + 1;

        _printLog("Idle from $_idleTimerTick seconds.");
        _printLog("Total Logout Time: $logoutTime seconds.");

        if (_idleTimerTick != null) {
          _printLog("Remaining: ${logoutTime - _idleTimerTick!} seconds.");
        }

        _dialogActivityCubit.updateCounter(_idleTimerTick ?? 0);

        if (_idleTimerTick! >= logoutTime) {
          _onTimerExceed();
        }

        //When 10 seconds are remaining
        else if (countDownBegan && !_dialogShown) {
          _dialogShown = true;
          showDialog(
                  context: globalNavigatorKey!.currentContext!,
            // context: context,
                  useRootNavigator: true,
                  builder: (final dialogContext) => TimerExceededWidget(
                        dialogActivityCubit: _dialogActivityCubit,
                        widgetBuilder: countDownWidgetBuilder,
                        logoutTime: logoutTime,
                        // timerTick: _idleTimerTick,
                      ) /*_timerExceededWidget(dialogContext)*/)
              .then((final value) {
            _dialogShown = false;
            if (value) {
              resetTimer();
            }
          });
        }
      } catch (e) {
        debugPrint(
            "[LOGOUT TIMER]Error in timer is is ${e.toString()} ${e.runtimeType}");
      }
    });
  }

  ///Boolean to check whether count down began or not
  bool get countDownBegan =>
      _idleTimerTick != null &&
      _idleTimerTick! >= (logoutTime - _countDownBuffer);

  ///Function to stop idle timer
  void stopTimer({bool fromLifeCycle = false}) {
    timer?.cancel();
    timer = null;

    if (!fromLifeCycle) {
      _idleTimerTick = null;
    }
  }

  ///Function to be called when idle timer is exceeded
  void _onTimerExceed() {
    _printLog("Timer Exceeded");
    stopTimer();
    _dialogActivityCubit.closeDialog();
    _dialogShown = false;
    onTimerExceeded();
  }

  ///Reset timer
  void resetTimer() {
    stopTimer();
    startLogoutTimer();
  }

  void onResume() {
    //Return if background time is null
    if ((_bgDateTime == null && _idleTimerTick == null) ||
        _bgDateTime == null) {
      return;
    }

    ///Check total background duration and add to idle timer tick
    DateTime current = DateTime.now();
    Duration duration = current.difference(_bgDateTime!);
    _bgDateTime = null;
    debugPrint("Entered Foreground");
    _idleTimerTick = _idleTimerTick! + duration.inSeconds;

    if ((_idleTimerTick! >= logoutTime)) {
      _onTimerExceed();
    } else {
      initiateTimer();
    }
  }

  void onPaused() {
    //Update background date time and stop timer
    _bgDateTime = DateTime.now();
    stopTimer(fromLifeCycle: true);
  }
}

class TimerExceededWidget extends StatelessWidget {
  const TimerExceededWidget(
      {super.key,
      required this.dialogActivityCubit,
      required this.widgetBuilder,
      required this.logoutTime});

  final DialogActivityCubit dialogActivityCubit;

  final Widget Function(int countDownTick, BuildContext context) widgetBuilder;

  final int logoutTime;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        width: 480,
        child: BlocBuilder(
          bloc: dialogActivityCubit,
          builder: (context, state) {
            int timerTick = (state is UpdateCounter) ? state.count : 0;

            return widgetBuilder(timerTick, context);
          },
        ),
      ),
    );
  }
}
