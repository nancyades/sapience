import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sapience/Services/apiservice.dart';

final addweekNotifier =
    StateNotifierProvider<addweekProvider, addweekState>((ref) {
  return addweekProvider(ref);
});

class addweekProvider extends StateNotifier<addweekState> {
  Ref ref;

  addweekProvider(this.ref)
      : super(addweekState(false, const AsyncLoading(), 'initial'));

  addweek(String sectionid, String termid, String monthid) async {
    state = _loading();
    final data =
        await ref.read(apiprovider).getWeek(sectionid, termid, monthid);

    if (data != null) {
      state = _dataState(data);
      if (state != null) {
        return state;
      }
    } else if (data == null) {
      state = _errorState('Timeout');
    }
    return state;
  }

  addweekState _dataState(dynamic entity) {
    return addweekState(false, AsyncData(entity), '');
  }

  addweekState _loading() {
    return addweekState(true, state.id, '');
  }

  addweekState _errorState(String errMsg) {
    return addweekState(false, state.id, errMsg);
  }
}

class addweekState {
  bool isLoading;
  AsyncValue<dynamic> id;
  String error;

  addweekState(this.isLoading, this.id, this.error);
}
