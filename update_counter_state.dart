part of 'update_counter_cubit.dart';

@immutable
sealed class DialogActivityState {}

final class UpdateCounterInitial extends DialogActivityState {}
final class UpdateCounter extends DialogActivityState {
  final int count;
  UpdateCounter(this.count);
}
final class CloseDialog extends DialogActivityState {
  CloseDialog();
}
