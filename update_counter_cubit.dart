import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'update_counter_state.dart';

class DialogActivityCubit extends Cubit<DialogActivityState> {
  DialogActivityCubit() : super(UpdateCounterInitial());

  void updateCounter(int count) {
    emit(UpdateCounter(count));
  }

  void closeDialog() {
    emit(CloseDialog());
  }
}
