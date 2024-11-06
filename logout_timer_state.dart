part of 'logout_timer_cubit.dart';

@immutable
sealed class LogoutTimerState {}

final class LogoutTimerInitial extends LogoutTimerState {}
final class LogoutTimerStart extends LogoutTimerState {}
final class LogoutTimerEnd extends LogoutTimerState {}
