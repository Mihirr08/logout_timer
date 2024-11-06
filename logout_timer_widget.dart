// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'logout_timer_cubit.dart';
//
// class LogoutTimerWidget extends StatefulWidget {
//   const LogoutTimerWidget(
//       {super.key,
//       required this.child,
//       required this.countDownWidgetBuilder,
//       required this.logoutTime,
//       required this.onTimerExceeded});
//
//   final Widget child;
//
//   final int logoutTime;
//
//   final VoidCallback onTimerExceeded;
//
//   final Widget Function(int countDownTick, BuildContext context)
//       countDownWidgetBuilder;
//
//   @override
//   State<LogoutTimerWidget> createState() => _LogoutTimerWidgetState();
// }
//
// class _LogoutTimerWidgetState extends State<LogoutTimerWidget>
//     with WidgetsBindingObserver {
//   late final LogoutTimerCubit _logoutTimerCubit;
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     _logoutTimerCubit = LogoutTimerCubit(widget.countDownWidgetBuilder,
//         widget.logoutTime, widget.onTimerExceeded, context);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _logoutTimerCubit.close();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     switch (state) {
//       case AppLifecycleState.detached:
//         break;
//       case AppLifecycleState.resumed:
//         _logoutTimerCubit.onResume();
//         break;
//       case AppLifecycleState.inactive:
//         break;
//       case AppLifecycleState.hidden:
//         break;
//       case AppLifecycleState.paused:
//         _logoutTimerCubit.onPaused();
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _logoutTimerCubit,
//       child: BlocConsumer(
//         bloc: _logoutTimerCubit,
//         listener: (context, LogoutTimerState state) {
//           if (state is LogoutTimerStart) {
//             _logoutTimerCubit.startLogoutTimer();
//           } else if (state is LogoutTimerEnd) {
//             _logoutTimerCubit.stopTimer();
//           }
//         },
//         builder: (context, state) {
//           return (kIsWeb)
//               ? MouseRegion(
//                   onHover: (state is LogoutTimerStart)
//                       ? (_) => _logoutTimerCubit.resetTimer()
//                       : null,
//                   child: widget.child)
//               : Listener(
//                   onPointerDown: (_) {
//                     (_logoutTimerCubit.timer != null)
//                         ? _logoutTimerCubit.stopTimer()
//                         : null;
//                   },
//                   onPointerUp: (_logoutTimerCubit.state is LogoutTimerStart &&
//                           !_logoutTimerCubit.countDownBegan)
//                       ? (_) {
//                           if (_logoutTimerCubit.timer == null) {
//                             _logoutTimerCubit.startTimer();
//                           }
//                         }
//                       : null,
//                   child: widget.child,
//                 );
//         },
//       ),
//     );
//   }
// }
